# SONICOURT · Build 105 · Rally-gated 60 fps recording, master-clock clips, exclusive watch matching

*2026-11-19 · Vincent Pluvinage with the cloud planning session · for the Mac session to implement, archive and upload · supersedes nothing; builds on 104.10.*

## 1 · Why, in numbers

From the 11/16 Menlo Circus Club run (build 104.8, Bruno on the TAPED half with the P2 watch, Ramiro on the BLOCKS half, 8 rallies, 84 hits, data in `TESTING/mcc-2026-11-16-b104.8-rally5/`):

| Finding | Number | Consequence |
| --- | --- | --- |
| Hits inside a rally are close together | median gap 1.57 s; 89 % of gaps under 3 s | With the 1 + 2 s window, consecutive clips overlap in 89 % of cases: within a rally the clips already form one continuous recording |
| Per-hit clips waste storage inside rallies | 27 clips × 3 s = 81 s for a 50.6 s rally; union 45.7 s | 44 % of clip bytes are duplicated frames |
| Rallies are a minority of the session | union of clip windows = 56 % of the play period, 38 % of the PLAY step, 26 % of the run | Recording between rallies would store 2 to 4 × more than the play needs |
| Clips are cut on the detection trigger, not the contact | contact lies 60 to 120 ms before the trigger, jitter independent per phone | Two clips of one hit can disagree by up to 100 ms; side-by-side replay cannot be synchronized today |
| The review plays one clip at a time | `ExternalDisplay` routes a hit's clip to its half's window; the other pauses | No paired view exists |
| Wrist spikes land on the wrong player | 68 hits carry a spike, 21 on Bruno's half, 47 on Ramiro's | The nearest-spike-within-1.5 s rule hands Bruno's swing to Ramiro's hit when the two alternate every 1.5 s |
| Soft hits are filed as landings | 84 hits vs 109 landings; 7.4 s and 5.9 s gaps inside rallies | Clip lists and rally sequences miss kitchen dinks |

Full analysis: documents 10, 11 and 12 of the planning package (ICP-Newsletter_temp, branch `claude/sonicourt-planning-architecture-vbyg2f`, folder `sonicourt/`).

## 2 · What build 105 changes

### 2.1 Rally-gated continuous recording at 1080p60, HEVC, hardware encoder

- Select a 1080p60 format on the back camera; stabilization off (as 92). The existing `AVCaptureVideoDataOutput` keeps feeding every consumer.
- An `AVAssetWriter` with an HEVC video input, `expectsMediaDataInRealTime = true`, bit rate 12 Mbit/s, on its own utility queue, never on the camera or audio tap queues. Frames are appended with their capture presentation timestamps (host clock), unchanged.
- **Gate:** the writer receives frames only while a rally is open. Rally open = the iPad's `serveListenOn`-to-first-HIT transition or the existing rally-open rule; rally closed = the rally gap (3/5/8 s picker) plus 2 s. Between rallies the encoder stays warm and the last 3 s of *encoded* sample buffers are held in a small ring (about 4.5 MB at 12 Mbit/s), so when a rally opens the file starts 3 s before its first frame.
- One file per rally: `<rec>-rally<R>-p<slot>-60.mov`, finalized at rally close. A crash loses one rally, not a session.
- **The JPEG ring is retired.** `FrameCamera` no longer compresses every frame. The three live consumers take a full-resolution pixel buffer on demand, no JPEG: the framing picture before play (every 0.5 s, downscaled for the iPad as now), the court-line fit (one frame every few seconds at start, between rallies and at each serve; frozen during a rally), and the serve gate (pose, band colour and ball on live frames while the word is armed, then the 12 MP still).
- The per-hit burst JPEGs and `-ball.json` are produced from the rally file after the rally closes (decode the 8 frames at −0.4…+0.5 s around each hit's contact, see 2.2), not live. The live feet vote for side fusion, if kept, uses the current frame at detection time.
- Storage: about 1.5 MB/s while a rally is open; at the 11/16 duty cycle about 2 to 2.5 GB per phone per hour of PLAY. Recordings leave the phone by USB; collect sends only requested clips.

### 2.2 Clips anchored on the master-clock contact

- The iPad already has, per confirmed strike, the contact time on the slot-1 master clock (`AcousticSolver.impactMs`) and the per-slot offsets and drift. For every hit it computes each phone's own sample index of the contact and sends it in `clipRequestN` (same message, new meaning: "the sample at which the paddle met the ball, on your clock").
- `PbapAudio` keeps the latest (`sampleTime`, `hostTime`) pair from the tap's `AVAudioTime` and exposes `hostMs(for nSample:)`; it subtracts `AVAudioSession.inputLatency`. The anchor resets on every engine restart (calibration epochs already mark these). Each `impacts.jsonl` row gains `hostMs`.
- A clip is cut from the rally file by timestamp: `[contactHost − 1000 ms, contactHost + 1500 ms]`, re-muxed without re-encoding (`AVAssetExportSession` passthrough or `AVAssetWriter` with the original samples), presentation time zero at `contactHost − 1000`, so the contact is at exactly 1.000 s in every clip from every phone. Name: `<rec>-strike<no>-p<slot>-c1000-clip.mov`; a sidecar `…-clip.json` carries `contactMasterSamples`, `contactHostMs`, `contactClipMs = 1000`, `fps`, `frames`.
- Live auto-clips (97.4) stay as an option for phones that have no iPad request; they are cut the old way and re-cut on request.

### 2.3 Synchronized paired review

- `SimpleFlow.reviewPlay` asks the two phones facing the hit's half (and optionally the two others) for the hit's clip. `clipURL` returns one URL per slot.
- `ExternalDisplay`: both players preloaded, `automaticallyWaitsToMinimizeStalling = false`, `preroll(atRate: 1)`, then `setRate(1, time: CMTime(1000 − leadMs, 1000), atHostTime: now + 200 ms)` on both. Pause, scrub, step (`step(byCount:)`) and half-speed (`rate = 0.5`) apply to both through one controller. The iPad mirrors the same controls.
- Whole-rally and last-4 modes play hit by hit with the paired start each time. A window whose clip has not arrived shows "fetching" and the other waits, so the pair never starts unsynchronized.

### 2.4 Exclusive watch-to-hit matching with the side rule

- Replace the per-hit nearest-spike rule in `SimpleFlow` (`WRIST-MATCH`, `WRIST-ALIGN`) with an assignment per rally: candidates are (spike, hit) pairs with |Δt| ≤ 1.5 s after the per-watch offset; cost = |Δt|; solve the minimum-cost one-to-one assignment (Hungarian or greedy-by-cost with exclusivity, the rally has at most ~30 hits); a spike may be assigned only to a hit on the wearer's half, where the hit's side is known; where the side is "?", the assignment is allowed and the side is set from the wearer.
- Unassigned spikes are logged `WRIST-ORPHAN n t g` and shown on the review map as a hollow marker on the wearer's half: evidence of a soft hit the loudness rule missed.
- Log per rally: `WRIST-ASSIGN rally R · watch Pk · spikes S · hits H · assigned A · orphans O · offset ±x s`.

### 2.5 Soft-hit recovery (do if it fits; otherwise log only)

- When a wrist orphan has no hit within 1.5 s on the wearer's half but the audio has a landing-class event within ±0.25 s on that half, reclassify the event as a hit with `soft: true`. Log `SOFT-HIT strike #n from wrist orphan`.

## 3 · Code map

| File | Change |
| --- | --- |
| `Sources/Camera/FrameCamera.swift` | 60 fps format; `AVAssetWriter` HEVC recorder with encoded pre-roll ring and rally gate; `currentFrame()` for on-demand full-resolution buffers; remove the JPEG ring; `cutClip(contactHostMs:)` from the rally file; `burstFrames(contactHostMs:)` decode |
| `Sources/Audio/PbapAudio.swift` | sample/host anchor; `hostMs(for:)`; `hostMs` in impact rows; input latency |
| `Sources/App/PhoneSession.swift` | rally open/close drives the recorder; clip request uses the contact sample; bursts and ball detection after rally close; live consumers take frames on demand |
| `Sources/App/SimpleFlow.swift` | contact-sample conversion per slot into `clipRequestN`; paired clip requests; exclusive wrist assignment; orphan and soft-hit logging |
| `Sources/App/ExternalDisplay.swift` | paired players on one host clock; shared transport controls |
| `Sources/Net/Mesh.swift` | `clipRequestN` semantics; clip sidecar in the file protocol; optional `rallyOpen/rallyClose` command if the phone does not already know |
| `project.yml` | `CURRENT_PROJECT_VERSION: "105"` |

## 4 · Acceptance in the driveway (runbook to be written with the build)

1. Ninety minutes with four phones: no CAPLAG, thermal state logged every minute from the heartbeat, battery logged every minute; compare with the 104.10 figures from the same afternoon.
2. Rally files: one per rally per phone, first frame ≥ 3 s before the first hit, last frame ≥ 2 s after the last, 60 fps measured from the timestamps, dropped frames reported.
3. Clips: contact at 1.000 ± 0.017 s in every clip; a flash or clicker visible in the same clip-local frame from both facing phones on twenty taps.
4. Paired review: both windows start together; step and half speed stay aligned; whole-rally mode plays the pairs in order.
5. Watch: a solo-practice block with one watch, then a two-player block with one watch; assigned spikes land only on the wearer's hits; orphans appear on the map on the wearer's half.
6. Storage: bytes per phone per PLAY minute reported at FINISH.

## 5 · Build and release steps for the Mac session

1. Pull `sonicourt-app` main. Save this spec at the repository root as `SONICOURT-BUILD-105-SPEC-2026-11-19.md`.
2. Implement 2.1 to 2.4 (2.5 if it fits), one commit per section, messages in the repository's style.
3. Set `CURRENT_PROJECT_VERSION` to `105`; `xcodegen generate`; build and run the three-simulator regression used for recent builds.
4. Write `RUNBOOK-DRIVEWAY-BUILD-105.md` from §4.
5. Commit and push main.
6. Archive in Xcode (Organizer), then upload to App Store Connect so build 105 reaches TestFlight for the kit iPad and the four kit phones; report the archive path, the upload result and any App Store Connect processing message.
7. Report back with the commit hashes, what was deferred, and the runbook.

## 6 · Out of scope for 105

The rally compilation export, colour recognition of the bands, the score machine, 120 fps, and any change to the acoustic solver or the click calibration.

---
© 2026 Vincent Pluvinage · SONICOURT — All Rights Reserved — Confidential and Subject to NDA
