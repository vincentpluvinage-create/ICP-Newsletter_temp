# 10 — Technical Evaluation: Side-by-Side Clip Replay Synchronized at Contact

Question: can the system replay two clips of the same hit, one from each side
of the net, so that the ball meets the paddle at the same instant in both?
Evaluated against `sonicourt-app` at build 104.10 on 2026-11-19.

## 1. Verdict

Not yet. The pieces exist but two things are missing. First, the clip on
each phone is cut around the time the impact was *noticed*, not the time the
impact *happened*, and that difference varies by roughly 50 to 120 ms per
phone. Second, the review screen plays one clip at a time: when a hit's
clip plays in the window of its half, the other window stays paused on its
last frame. Neither is hard to fix, and the fix needs no cross-phone clock
at all, because each phone's microphone and camera already share one clock.

Target after the fix: both clips aligned at contact to within half a frame
(±17 ms at 30 fps, ±8 ms at 60 fps), with the contact instant itself known
to about a millisecond.

## 2. How a clip is produced today

| Step | Where | What happens |
| --- | --- | --- |
| Camera frames | `FrameCamera.captureOutput` | Each frame is JPEG-compressed and stored in a 135-frame ring with its presentation timestamp in host milliseconds (`hostMs`). 1080p, about 30 fps, stabilization off. |
| Impact detected | `PbapAudio.process` | The impact's onset is stamped with the audio sample index `nSample`, accurate to one sample. The tap delivers blocks of 2048 samples (43 ms), so the callback runs up to 43 ms after the onset. |
| Trigger chosen | `FrameCamera.saveBurst` | The trigger is `ring.last.hostMs`, the newest frame in the ring at the moment the burst is requested. The impact's sample index is never converted to host time. |
| Clip cut | `FrameCamera.recordPrerollClip` | Frames with `hostMs` in [trigger − 1000, trigger + 2000] are encoded to H.264. Presentation time zero is the first frame's own timestamp, so the contact sits somewhere between 0.97 and 1.10 s into the clip, different in every clip. |
| Confirmed strike | `SimpleFlow` → `clipRequestN` | The iPad names the strike and each phone's own onset sample; the phone looks up the trigger it recorded for that sample and cuts the clip. |
| Review | `ExternalDisplay.clipWindow` | Two `AVPlayer`s, one per half. The current hit's clip is routed to its half's window and played; the other window pauses where it is. No shared clock, no synchronized start. |

The code's own comment states the latency: "contact ≈ trigger − (block
latency 0–100 ms + flight 15–25 ms)", and the ball-detection heuristic
looks for the frame nearest 60 ms *before* the trigger for that reason.

## 3. Error budget of the current method

| Term | Size | Same on both phones? |
| --- | --- | --- |
| Audio block latency (onset to callback) | 0 to 43 ms | No, random per phone |
| Sound flight from paddle to microphone | 6 to 22 ms (7 to 25 ft) | No, depends on each phone's distance to the hit |
| Dispatch and queue hops before the ring is read | a few ms, up to tens under load | No |
| Trigger snapped to the newest frame | 0 to 33 ms early | No |
| Clip time zero at the first frame's timestamp | 0 to 33 ms | No |

Summed, each clip's contact lies 60 to 120 ms before its nominal trigger with
independent jitter, so two clips cut this way can disagree by up to about
100 ms, three frames at 30 fps. That is why the memo for Bruno promises the
pairing only after the fix below.

## 4. The fix: anchor each clip to its own phone's audio clock

The insight is that every phone already has the two things needed, on one
clock. The audio engine's `AVAudioTime` carries both `sampleTime` and
`hostTime`, and the camera's presentation timestamps are on that same host
clock. Nothing from the other phone is needed to place the contact in a
clip.

1. **Record the sample-to-host anchor.** In `PbapAudio.process`, keep the
   latest pair (`when.sampleTime`, `when.hostTime` converted to
   milliseconds). Any sample index then maps to host time:
   `hostMs(n) = anchorHostMs + (n − anchorSample) / 48`. Write this `hostMs`
   into each `impacts.jsonl` row beside `nSample`, `upMs` and `wallMs`.
2. **Subtract the sound flight.** The iPad's four-mic solver (104.7) knows
   the contact point, so it knows each phone's distance `d_i`. Send
   `d_i` with the clip request, or send the contact point and let the phone
   compute it. The contact instant on phone i is
   `contactHostMs_i = hostMs(n_i) − d_i / c − inputLatency`, with
   `c` from the temperature model and `inputLatency` from
   `AVAudioSession.inputLatency` (measured at 0.9 to 1.4 ms on the kit
   phones). Without the flight correction the two clips still disagree by
   the flight difference, up to 15 ms between the near and far camera.
3. **Cut on the contact, not the trigger.** `recordPrerollClip` takes
   `triggerHostMs`; pass `contactHostMs_i`. Set the clip's presentation
   time zero to `contactHostMs_i − preMs` rather than the first frame's
   timestamp, so the contact is at exactly 1.000 s in every clip. Frames
   keep their true timestamps relative to that zero, so cadence stays
   honest and a dropped frame shows as a gap, not a slip.
4. **Write the contact into the file.** Put `contactMs` (clip-local) and
   `contactHostMs` in the clip's name or a sidecar JSON, so playback and
   the offline tools never have to rediscover it.

After this, aligning two clips means starting both at the same clip-local
time. The residual error is the frame interval, since the contact falls
between two frames: ±17 ms at 30 fps, ±8 ms at 60 fps.

## 5. Synchronized playback on the iPad and the monitor

Two `AVPlayer`s can be started together on one host clock:

- Preload both items, set `automaticallyWaitsToMinimizeStalling = false`
  and call `preroll(atRate: 1)` on each.
- Start both with `setRate(1, time: CMTime(contactMs − leadMs), atHostTime: hostNow + 200 ms)`.
  Both players then begin at the same media time at the same host instant.
  Pausing, scrubbing and stepping apply to both through one controller.
- Frame stepping for teaching: `currentItem.step(byCount:)` on both
  players, since both clips carry their frames at true timestamps the
  steps stay aligned to within the frame interval.

For export, the same alignment becomes a single file: an
`AVMutableComposition` with two video tracks, each inserted with its own
time offset so the contacts coincide, and an `AVMutableVideoComposition`
that places them left and right (or stacked for a vertical social-media
crop) with the court diagram and label overlaid. This is the renderer the
rally compilation already needs, so the two features share one path.

## 6. What limits the visible result

- **Frame rate.** At 30 fps a 50 mph drive moves the ball 37 cm between
  frames, so "ball on the paddle" is often not in any frame. At 60 fps it is
  18 cm, at 120 fps 9 cm. The alignment will be exact in time even when
  neither clip holds the contact frame; for the viewer's eye, 60 fps is the
  minimum and 120 fps is worth it for drives. The JPEG ring cannot run at
  that rate; a continuous hardware-encoded recording (document 06 §2.3)
  can, and clips are then cut from the file by timestamp.
- **Rolling shutter.** A 1080p sensor reads out over roughly 10 to 20 ms
  from top to bottom, so a fast paddle is drawn slightly skewed and its
  position depends on its row. Irrelevant for sync, visible in stills.
- **Dropped frames.** `alwaysDiscardsLateVideoFrames` is on, so under load
  a frame disappears. With true timestamps the clip simply holds the
  previous frame for 66 ms; the alignment is unaffected.
- **Different phones, different exposure.** The two cameras face different
  halves, often one into the sun. Matching exposure is a presentation
  choice, not a timing one.

## 7. How to verify

1. **Bench test with one phone.** Tap a paddle against a ball in front of
   the camera with a visible flash (the impact beacon of document 07 M5, or
   a camera flash fired by a clicker). The flash frame gives the contact in
   video; compare with `hostMs(n)` from audio. Expect agreement within one
   frame over fifty taps, after the flight and latency corrections.
2. **Two-phone test.** Same taps seen by both post cameras. Cut clips with
   the new method, align at `contactMs`, and check that the flash appears
   in the same clip-local frame in both. Expect zero disagreements beyond
   one frame.
3. **Field check.** For twenty rally hits, step both clips to the contact
   frame by eye and record the difference in frames. Report the
   distribution; the goal is a median of zero and no case beyond one.

## 8. Effort

Steps 1 to 4 of §4 are about a day of phone-side work plus a session to
verify. The synchronized dual player is a day on the iPad. The composition
exporter is two to three days and is shared with the rally compilation. The
continuous 60 fps recording is the larger item and is already on the plan.
