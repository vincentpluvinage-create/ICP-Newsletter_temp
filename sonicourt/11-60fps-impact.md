# 11 — System Impact of Recording Clips at 60 fps

Companion to document 10. Question: what changes if the phones record at 60
frames per second instead of 30, for tighter contact sync and half-speed
replay? Evaluated against build 104.10 on 2026-11-19. Figures marked
"estimate" are engineering estimates, not measurements.

## 1. Verdict

Worth doing, but not by turning the existing JPEG ring up to 60. The ring
compresses every frame on the CPU and is already the documented thermal
load; doubling it would starve the audio pipeline the way the chirp
correlation did in August. The way to get 60 fps is a continuous
hardware-encoded recording beside a smaller live stream, which costs the
phone less than today's ring does and makes clips real video. Half-speed
replay then plays at a smooth 30 fps, and sync tightens from ±17 ms to
±8 ms.

## 2. What 60 fps buys

| Benefit | At 30 fps | At 60 fps |
| --- | --- | --- |
| Contact alignment residual (contact falls between frames) | ±17 ms | ±8 ms |
| Ball travel between frames, 50 mph drive | 37 cm | 18 cm |
| Ball travel between frames, dink at 5 m/s | 17 cm | 8 cm |
| Half-speed replay | 15 fps, visibly steppy | 30 fps, smooth |
| Quarter-speed replay | 7.5 fps, unusable | 15 fps, usable for stills-like study |
| Motion blur per frame, auto exposure in daylight | typically 1/60 to 1/120 s shutter anyway | shutter capped at 1/60 s or faster; less blur in dim light is not available |

The frame nearest contact also improves the feet, paddle and ball
measurements that run on burst frames, since the nearest frame is on
average half as far from contact.

## 3. What it costs in the current architecture (the JPEG ring)

| Resource | Today, 30 fps | At 60 fps, same design |
| --- | --- | --- |
| CPU for JPEG compression (estimate: 8 to 15 ms per 1080p frame through Core Image) | 25 to 45 % of one core | Exceeds the 16.7 ms frame budget on a busy phone; frames drop (`alwaysDiscardsLateVideoFrames` is on) and the camera queue backs up |
| Ring memory for 4.5 s | 135 frames, 30 to 45 MB | 270 frames, 60 to 90 MB, or halve the history to 2.25 s |
| Clip encoding from JPEGs | decode 90 frames, encode H.264 | decode 180 frames; roughly double the time per clip, on the utility queue |
| Thermal | already the early-warning item; CAPLAG stalls in August were traced to CPU starvation | likely to reproduce them |
| Court fit, ball detector, serve photo | unaffected, they read single frames | unaffected |

So the ring design should stay at 30 fps for its own purposes, or shrink.

## 4. The design that supports 60 fps

1. **Continuous HEVC recording through the hardware encoder.** Feed the
   camera's sample buffers to an `AVAssetWriter` at 1080p60. The encoder is
   a dedicated block, so CPU cost is small (estimate: a few percent of a
   core). Rotate the writer into segment files at rally boundaries or every
   minute so a crash loses a minute, not a session. On iOS a session cannot
   carry both a movie-file output and a video-data output, so the writer is
   fed from the existing data output, which keeps every current consumer.
2. **A small live stream for vision.** From the same buffers, take every
   second or fourth frame, downscale to about 640 × 360, and keep that as
   the ring for framing, the court fit, the feet vote and the serve-photo
   gate. The full-resolution JPEG burst around a hit can stay, since it is
   eight frames per hit, not every frame.
3. **Clips cut from the recording by timestamp.** The recording carries
   presentation timestamps on the same host clock as today's ring, so the
   contact instant from document 10 maps straight into it. Cutting is a
   re-mux of the HEVC samples between two timestamps, no re-encoding, which
   is faster than today's JPEG-to-H.264 path.
4. **Optional 120 fps for drives.** The same pipeline runs at 1080p120 on
   the kit phones; bit rate and heat rise, the live stream decimates by
   eight. Use it for drive and serve blocks only.

## 5. Costs of the new design

| Resource | 1080p30 HEVC | 1080p60 HEVC | Note |
| --- | --- | --- | --- |
| Bit rate (estimate, encoder default quality) | 6 to 8 Mbit/s | 10 to 14 Mbit/s | Set explicitly; quality for coaching needs the higher end |
| Storage per phone per 90 min | 4 to 5 GB | 7 to 9 GB | 128 GB kit phones hold several sessions; delete after the USB pull |
| Storage per 3 s clip | 2.5 to 3 MB | 4 to 5 MB | Two clips per hit |
| Collect over Wi-Fi Aware | — | Cut only the clips the review asks for; the full recording leaves by USB | 400 hits × 2 clips ≈ 3.5 GB is too much for the mesh |
| Battery (estimate) | — | Encoder adds a few percent; the removed JPEG work saves more | Net neutral or better than today |
| Thermal | — | Encoder is efficient; the sensor at 60 fps draws a little more | Lower than today's ring on a hot afternoon, by estimate; measure |
| Serve photo interleave | ring gap of one or two frames | gap is the same in milliseconds, twice the frame count | unchanged in effect |
| iPad playback and monitor | — | 60 fps HEVC decodes in hardware; the monitor runs at 60 Hz | half speed is 30 fps on screen |

## 6. Side effects to watch

- **Exposure in dim light.** At 60 fps the shutter cannot exceed 1/60 s, so
  late-afternoon shade gets darker frames or higher gain. Daylight is
  unaffected.
- **Rolling shutter** is unchanged; a fast paddle still skews slightly.
- **Audio pipeline priority.** The writer must run on its own queue below
  the audio tap, as the ring's encoder does now; the August lesson applies.
- **Frame drops under load** now land in the recording as timestamp gaps,
  which the clip cutter must tolerate (it does, since frames carry true
  timestamps).
- **Disk writes.** A 12 Mbit/s stream is 1.5 MB/s; the August fix moved
  audio writes off the tap thread for exactly this reason. Keep the writer
  off that thread.

## 7. Recommendation

Build the continuous recording at 1080p60 with the decimated live stream,
keep the JPEG burst per hit, cut clips by timestamp, and pull full
recordings by USB. Measure thermal state, dropped-frame count and battery
over a 90-minute driveway session before the pro sessions. Offer 120 fps as
a per-block option once 60 is stable.
