# Build 105 — code review against the specification

**Confidential and Subject to NDA.** Sonicourt / Invention Capital Partners. Reviewed 2026-11-19 on `vincentpluvinage-create/sonicourt-app`, `origin/main` at `f83afb7` (seven commits: 3d39ab7, 3d59e0f, 1df3ece, ae283cb, 923b565, 9b860e1, f83afb7). Spec: `SONICOURT-BUILD-105-SPEC-2026-11-19.md`.

## 1. Verdict

The implementation follows the specification in every section. No blocking defect found in a read-through of all changed files. Nothing has yet run on a phone; the acceptance tests of spec §4 (runbook blocks 1–5) are the next step and the only way to validate the timing claims.

| Spec section | Status | Where |
|---|---|---|
| 2.1 Rally-gated 1080p60 HEVC recording | Implemented | `Sources/Camera/RallyRecorder.swift` (new), `FrameCamera.swift`, `PhoneSession.swift`, `Mesh.swift` (`rallyGate`) |
| 2.2 Clips anchored on the master-clock contact | Implemented | `SimpleFlow.contactSamples`, `PbapAudio.hostMs(for:)`, `PhoneSession.cutStrikeClip`, `RallyRecorder.cutClip` |
| 2.3 Synchronized paired review | Implemented | `ExternalDisplay.swift` (`PairedPlayback`, `ReviewTransport`) |
| 2.4 Exclusive watch-to-hit assignment | Implemented, with a justified deviation (window) | `Sources/App/WristAssign.swift` (new), `SimpleFlow.assignWrist` |
| 2.5 Soft-hit recovery (optional) | Marking only, as allowed | `SOFT-HIT?` log line, `softHitCandidate` in the strikes JSON |
| 3 Code map | Matches | — |
| 5 Build/release | Version 105 in `project.yml`; runbook present; archive and upload done by the Mac session (not verifiable from here) | `RUNBOOK-DRIVEWAY-BUILD-105.md` |

## 2. What was checked, section by section

### 2.1 Recording
- Encoder: VideoToolbox HEVC, real-time, no frame reordering, 12 Mbit/s, key frame every 0.5 s. Encoding runs on its own queue; the camera delegate hands the pixel buffer off and returns. Frames are dropped when more than 4 are pending, which protects the capture pipeline under thermal pressure.
- Pre-roll: an **encoded** ring of 8 s (spec asked for at least 3 s) that always starts on a key frame, so a rally file opened at "first hit − 3 s" begins decodable. The 8 s is cheap (about 12 MB) and gives margin for a late gate.
- Gate: the iPad sends `rallyGate(open:rally:n:tailS:)` at the first confirmed hit with the contact sample for each phone, and `close` at rally close with a 2 s tail. Mesh de-duplicates repeats within 3 s. The phone opens `<rec>-rally<R>-p<slot>-60.mov` from `hostMs(firstHit) − 3000 ms`, or `now − 4500 ms` when the anchor is missing; it refuses when free space is under 1 GB, and avoids name collisions.
- Orphan rallies (no close received) are closed after 30 s by the watch tick. A HEALTH line each minute reports thermal state, battery, fps, frames, drops, encoder errors, files, MB and free GB; FINISH writes a STORAGE line with MB per PLAY minute, which is exactly what §1 of the spec needs measured.
- Full-resolution frames on demand: `currentFrame()` for the serve-photo gate and court fits; the JPEG ring is gone; `-60.mov` files are excluded from the Wi-Fi collect (USB pull only), as specified.
- Court and pink-line fits are skipped while a rally file is open (`recRally != 0`), so the homography stays frozen during play.

### 2.2 Contact anchoring
- iPad side (`contactSamples`): the contact on the master clock is the solver's impact time when it sits 0–40 ms before the first arrival, else first arrival − 10 ms, and the log says which. For a phone that heard the hit, contact on its own clock = own arrival − (its master-clock arrival − contact), which removes that phone's own flight time. A phone that did not hear the hit gets the master contact carried through `quadTheta(from: 1, to: slot, at:)`, i.e. offset and drift at that instant. All four phones therefore cut the same physical instant.
- Phone side: `PbapAudio` keeps a (sample, host time) anchor from each tap buffer's `AVAudioTime.hostTime`, subtracts input latency, resets on `start()`. `cutStrikeClip` refuses a request when the anchor is missing or from an older clock epoch, then cuts `[contact − 1000 ms, contact + 1500 ms]` as a passthrough copy with the contact at 1.000 s; the sidecar JSON carries `contactClipMs: 1000`, the master sample, the own sample and the host time.
- `RallyRecorder.tryCut` polls every 80 ms until the tail frames exist (the request arrives 0.1–0.3 s after the hit, the window ends 1.5 s after it), falls back to the finalized rally file, or waits for the open file to close. The 8 s ring always covers the 2.5 s window.
- Camera PTS are converted with `CMSyncConvertTime` from the capture session's synchronization clock to the host clock, so audio and video meet on one time base.

### 2.3 Paired review
- Four `AVPlayer`s with `automaticallyWaitsToMinimizeStalling = false` and `sourceClock` = host clock; both items prerolled, then `setRate(1, time: t, atHostTime: host + 200 ms)` on each, so they start at the same host instant. Half speed, scrub and single-frame step share one transport. Step is a seek by 1/frameRate because `AVPlayerItem.step` moved 0.25 s on the Mac's test; fine for 60 fps content.
- With the contact at 1.000 s in every clip, playing both from `t = 0` aligns the hit; no per-pair offset is needed, which is the point of §2.2.

### 2.4 Watch assignment
- `WristAssign.assign` is greedy and exclusive: strong spikes first, each hit takes at most one spike, each spike at most one hit, with the side rule (`allowed(hit, wearer:)`): a hit on the wearer's half or unsided. Orphans are returned and logged as `WRIST-ORPHAN`; `WRIST-ASSIGN` per rally and watch gives spikes, hits, assigned, orphans, offset and window.
- Time base: hits are placed on wall time through `hitClockC`, the least-delayed strike so far (reset after a 120 s jump, i.e. a restarted recording on slot 1). Spikes are placed by the watch's motion clock through a per-watch bridge (minimum of wall − t), so the batch-delivery delay of 0–0.9 s that caused the 47/68 mis-assignments in 104.8 no longer enters the match. Per-watch offset is measured at rally close on the whole session (`measureOffset`, cluster of spike − hit, minimum support 4).
- **Deviation from spec:** matching window 0.25 s when the offset is measured, 0.40 s when not, instead of the 1.5 s I wrote. The Mac's reasoning is sound: 1.5 s was sized for the wall-clock delivery delay, which the motion-clock bridge removes; with hits 1.0–1.6 s apart a 1.5 s window would let a spike reach the neighbouring hit. Accept, but acceptance test 5 must confirm the bridge on real data (the offset should come out stable within about ±0.1 s across rallies).
- Live assignment every second while a rally is open fills the wrist fields for the review; the final pass at close re-measures and logs.

### 2.5 Soft hits
- A landing-class sound within 1.5 s of a wrist orphan on the wearer's half is marked `SOFT-HIT?` and `softHitCandidate: true` in the strikes JSON. Not counted as a hit, as the spec allowed. Good for the 84-hits-versus-109-landings question; a counting decision waits for data.

## 3. Risks to watch in the driveway run (runbook blocks 1–5)
1. **Thermal.** Continuous 1080p60 encode plus 48 kHz audio on four phones for a 90-minute session has not been run. The HEALTH line will show it; if `thermalState` reaches serious, the encoder drops frames before the audio path is affected, which is the right priority.
2. **Anchor validity.** `hostMs(for:)` depends on `isHostTimeValid` on every tap buffer. If a phone's audio engine restarts mid-session the anchor resets; the sidecar JSON records the epoch so a stale clip can be identified afterwards.
3. **Gate arrival vs pre-roll.** The gate opens at the first *confirmed* hit, which can be a second or more after the sound when confirmation waits for the quad. The 8 s ring covers it; the file start is still placed at hit − 3 s.
4. **Contact source.** Without a click calibration the contact is first arrival − 10 ms; flight to the nearest phone is 10–40 ms, so clips can sit up to 30 ms (about 2 frames at 60 fps) early relative to true contact. The log names the source so the acceptance check can separate the two cases.
5. **Storage.** At 12 Mbit/s, one minute of rally time is about 90 MB per phone. With rallies at about 38 % of the PLAY step, expect roughly 35 MB per PLAY minute per phone; the STORAGE line will give the real number.

## 4. Not verifiable from this session
- Xcode Organizer archive and App Store Connect upload (done on the Mac; confirm the build appears in TestFlight).
- Any runtime behaviour; the Mac's three-simulator regression exercised the iPad logic only.
