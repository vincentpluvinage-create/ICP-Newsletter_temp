# 08 — Invention Inventory for the Comprehensive Provisional

Prepared 2026-11-19 from a full review of `sonicourt-app` at build 104.10
(specs and memos, 66 runbooks, the three session reports and analysis tools
in `TESTING/`, all Swift sources), the two filed provisionals in Google
Drive, and this session's discussion. It is an engineering inventory, not
legal advice. Status codes:

| Code | Meaning |
| --- | --- |
| **F** | Disclosed in the filed July 18, 2026 provisional (64/114,681) |
| **F-** | Partly disclosed there; the newer form is not |
| **U** | Built or specified in the repository, not in any filing |
| **N** | New in this session (2026-11-19), in no document before document 07 |

Evidence column gives the build, the date as written in the source, and the
measured result where one exists. Dates matter for the record of
conception and reduction to practice.

## 0. Filings on record and deadlines

| Serial | Filed | Subject | Twelve-month deadline |
| --- | --- | --- | --- |
| 64/084,727 | 2026-06-07 | CLUB77 text-message round-robin scoring (identity by phone-number hash, rotation template, idempotent writes, integrity safeguards, zero-install display) | 2027-06-07 |
| 64/114,681 | 2026-07-18 | Sonicourt sensing: net-post fixtures, two phones per post, on-device transient detection with sample index, level-based side and court, one-way chirp anchoring and hyperbolic TDOA, near-ultrasonic handshake, acoustically triggered stills, rally grammar, participant-confirmed scoring; 35 aspects, 46 claims, FIGS 1–21 | 2027-07-18 |

The repository's "provisional v7" (referenced 2026-08-07) and "supplement 3"
(wrist logger, build 73, about 2026-08-18) do not appear in the Patent
Center receipt history quoted in the SLW log of 2026-11-17. Everything from
build 26 (iPad-on-T calibration, 2026-08-05) onward is therefore unfiled.
The July application states it claims no priority from the June one and
incorporates it by reference only.

Practical consequences:

- The new provisional should be filed before the pro sessions, or the
  sessions held under written confidentiality. Document 05 §5 explains why.
- A non-provisional or PCT claiming the July provisional is due by
  2027-07-18. The new provisional will have its own twelve-month clock; the
  eventual application can claim both.
- Schwegman Lundberg is already engaged by ICP for the silicon-anode matter
  and could take this one.

## 1. Concept inventory

### 1.1 Acoustic capture and event detection

| # | Concept | Status | Evidence |
| --- | --- | --- | --- |
| A1 | Sample-indexed capture on the hardware audio clock; impacts stamped to one sample, never wall or callback time | F | July filing aspect 7; `PbapAudio` |
| A2 | Crest-factor transient discriminator with two paths (crest ≥ 20; crest ≥ 16 and peak ≥ −30 dB) tuned on a recorded clap-and-speech session; zero speech leaks | F- (July recites onset, duration, spectral shape; the crest-factor rule is new) | Clap session 2026-08-03, 50/50 claps, 0 speech; driveway pops recovered 7/10 misses |
| A3 | Quiet-before path: crest ≥ 14, peak ≥ −28 dB, jump ≥ 20 dB over previous block | U | Build 77, 9/27 far-corner hits crest 14.3/15.7; +25 fires per phone-hour offline, all impulsive |
| A4 | Onset picker on a band-passed stream (2.5–9 kHz, first sample ≥ 10 % of peak, 20 ms look-back) with rise, late-dB and onset-shift diagnostics per row | U | Build 78; wall reflection stamped 1.1–1.6 ms late (18–20 in); offline 9 pairs rms 0.59 ms |
| A5 | Dual rings (raw plus band-passed) so the matched filter reads filtered audio at no extra cost; chirp correlation only inside scheduled windows | U | Builds 74–75; tap-thread starvation 8/18 and 8/24 |
| A6 | Impact PCM window (−100/+30 ms) shipped per event for cross-device re-timing, audio otherwise never leaves the phone | U | Build 90 |
| A7 | Hit versus landing by level at every post (hit ≥ −24 dB at each post that heard it; landings −27 to −36 dB), and lateral position beyond ±130 in treated as a ball landing | U | Builds 99/100.1; 97.4 auto-clip threshold |
| A8 | Paddle versus bounce by 4–12 kHz brightness | F | July FIG. 19 |
| A9 | Extra sensitivity window during the serve ritual (boost dB) | U | 101.5, 11/11 |
| A10 | Capture integrity: liveness stamped at the bottom of the audio pipeline, self-heal watchdog, sample-clock-versus-wall lag monitor with restart budget, built-in mic pinned against Watch and AirPods route theft, interruption and media-reset recovery | U | Builds 39, 61, 64, 66, 102.3; 8/7 "announcer death", 8/15–16 CAPLAG |
| A11 | Session-stamp collisions avoided by post id; timing anchors nSample, uptime and wall per row | U | Builds 26, 38 |

### 1.2 Synchronization and calibration

| # | Concept | Status | Evidence |
| --- | --- | --- | --- |
| S1 | One-way coded acoustic reference heard by all devices; TDOA as sample-count difference | F | July aspect 7, 21 |
| S2 | iPad placed on the kitchen T, equidistant from both post mics, emits chirps; arrival difference is the clock offset directly; phones never emit | U | Build 26, 2026-08-05; spread 0.19–0.38 ms on 10/26 |
| S3 | Stereo speaker alternation (left-only, right-only chirps) gives a ±0.25 ms signature that identifies which phone is on which post | U | Build 26 |
| S4 | Robust chirp-index solve: arrivals bucketed by known spacing, ladder alignment, ±1 ms echo rejection, per-speaker-group spread, quality gate with automatic retry | U | Builds 29, 73, 75; 8/18 club 0.8–1.0 ms spread biased θ by 3 ms |
| S5 | Two-way chirp exchange between phones: half-sum cancels the propagation delay to give the clock offset, half-difference gives the distance | U | Build 31, 2026-08-06; bench 2026-07-22 drift −7.84 ppm |
| S6 | Round-robin with the iPad listening: three two-way distances and triangle closure against the kitchen-T geometry separate placement error from scale error | U | Build 39, 2026-08-09 |
| S7 | Dual-solve placement gauge: θ from listening versus θ from two-way exchange, difference in inches of iPad displacement (0.12 ms per inch) | U | 2026-08-06 driveway 0.60 ms ≈ 8 in; 9/27 10 in off bisector gave 2.2 ms |
| S8 | Ping loop: silent two-way exchanges on a timer, only in rally gaps, drift fitted from the ping series which overrides any calibration slope; reject implausible slopes (≥ 40 ppm) and ranges | U | Builds 89–90.3, 97.3, 99; 10/26 ping-maintained θ gave hit rms 4.7 in versus 21.7 in frozen; 10/28 −6.2 ppm from 41 pings |
| S9 | Four-phone symmetric calibration: scheduled emission slot per phone, three-chirp trains attributed by schedule, all six pairs solved per round with per-pair offset, distance and drift; loop closures logged; rigid same-post pair constraint; record-latency bias measured from far chirps heard by both phones of a post | U | Builds 97–100.2, spec 2026-10-30; 11/07 six-pair drifts −17 to +1 ppm, same-post 7.6/7.8 in, across 250–253 in |
| S10 | Earliest-lobe arrival picker for doublet arrivals (two iPad speakers, ground bounce) with band-passed matched filter | U | Builds 75–76, 9/27 ladder; 28 % of chirps had landed on the later lobe |
| S11 | Hybrid first-wavefront re-timing: band-pass, onset at 8× noise floor, NCC of the first-wavefront segment, sub-sample peak, used only above an NCC gate, with a per-session constant from a reference position | U | Build 90, offline 10/26 rms 5.8 → 4.2 in; 10/28 78/80 re-timed, D1 constant +0.35 ms |
| S12 | Clicker calibration: three clicks at the T and both kitchen-line ends, sorted to spots by their own sound in any order, solving pair latency offsets and the same-post microphone separation and axis | U | 104.7–104.10, 2026-11-16/18; clicks clean at 7, 13, 22 ft |
| S13 | Speed of sound from hourly air temperature | U | Build 63; 8/15 fixed value read the baseline 1.7–2.3 in low |
| S14 | Clock-epoch guards: calibration and command epochs, θ invalidated on engine restart, cross-checks between references | U | Builds 52, 58, 74; 8/11 restart fit +871.8 ppm rejected |
| S15 | T-bounce as a single gesture calibrating pair bias, watch clock, wrist-to-paddle delay and feet homography | U (proposed) | Protocol v2, 2026-10-31 |
| S16 | Watch clock bound to the net clock by the pattern correlation of wrist spikes against acoustic hits, realigned at rally close | U | 99.6, 104.2; watch clock 0.3–1.3 s ahead |

### 1.3 Localization and side-of-net

| # | Concept | Status | Evidence |
| --- | --- | --- | --- |
| L1 | Hyperbolic TDOA on the inter-post baseline; small-baseline bearing; GDOP analysis | F | July aspects 7, 21 |
| L2 | Side and court from level comparison of opposed phones; neighbour rejection by intensity pattern | F | July claim 1 |
| L3 | Off-court gate scaled to the declared or measured baseline, graduated (accept < 0.45 τ, reject > 0.60 τ, feet decide between) | U | Builds 26, 42, 48; 8/9 corner serves rejected under the wrong baseline |
| L4 | Side of net from the sum of the two same-post time differences against a measured zero (T clicks or T bounces), with thresholds either side and the cameras deciding the band between | U | Builds 97–100.2; 100 % side-of-net in four sessions; taped −0.4 to −0.9 ms, blocks +0.17 to +0.47 ms |
| L5 | Four-mic contact-point solver: post-to-post pairs give x, same-post pairs give bearing (the only acoustic depth), same-post pairs weighted 3×, grid then refinement | U | 104.7, 2026-11-16 |
| L6 | Four-arrival clustering on a master clock with lone-row waiting and late-row rejoin; geometry gates per pair | U | Build 97–97.3; 11/07 22 four-phone hits all on the correct side |
| L7 | Echo rejection by cross-pairing within the geometric window and a 350 ms pad refractory | U | Build 72 |
| L8 | Per-phone onset-shape bias identified from corner data; phone swap as the decisive test | U (open) | 10/26 and 10/28 reports: A1 bias +12 to +14 in on one phone |
| L9 | Acoustic-versus-camera consistency as a timing check: ball bearing and range from the strike burst compared to acoustic x | U | Build 79, 10/28 fusion: camera scatter 4 in, acoustic 6.5–6.8 in |

### 1.4 Vision and court geometry

| # | Concept | Status | Evidence |
| --- | --- | --- | --- |
| V1 | Acoustically triggered stills from a rolling pre-roll buffer, bursts at offsets | F | July aspect 17 |
| V2 | Rolling full-rate JPEG ring with retroactive strike bursts and pre-roll clips (−1 s/+2 s) encoded with host-time stamps | F- (clips are new; July avoids video) | Builds 41, 45, 78 |
| V3 | Automatic homography from painted lines: court-hue hull, top-hat paint validation, adjacency naming, centreline RANSAC, local refinement; validated on club photos | U | Build 47, study 2026-08-10: 38/38 side calls with no calibration input |
| V4 | Pose-constrained court fit: camera position fixed by the fixture chain, focal from the two-camera study, only three mount angles fitted; four hypotheses (post side × lens height) select themselves | U | Build 70, 2026-08-17; RMS 1.2–1.4 px |
| V5 | Dense paint-offset consistency signal; side votes accepted through amber, fault calls only on green | U | Build 70; thresholds 5 and 12 px |
| V6 | Ankle midpoints through a ground homography (box centres carry parallax) | U | Study 2026-08-10: zero overlap across 45 serves in court space |
| V7 | Rule-true calls: left half, right half, fault by sign tests at the anchor lines; only the across-court camera judges faults | U | Builds 47, 74; 8/24 near-camera false faults |
| V8 | Server identification by ball-near-wrist plus behind-baseline position; per-serve preference for the server's-side camera | U | Study 2026-08-10: ball median 23 px from wrist |
| V9 | Pink-line fit for taped courts: colour mask, iterative Hough, line identification from the camera's own view geometry, DLT from four intersections; white-line mode seeded from the fixture aim | U | Build 93b–94, 2026-11-01/02; two cameras agree on feet to 9 in |
| V10 | Four-dot pose snap from known fixture height, gravity pitch and roll, device intrinsics; centre line as shared backbone between cameras; must-contain corridor boxes; adaptive four-class colour model; corner-first search with junction templates | U (specified, partly prototyped) | Framing v2, 2026-10-31 |
| V11 | Ball detector with per-session learned colour gate; range from apparent diameter, bearing from column | U | Builds 79–80; 21 px at 15 ft, 13 px at 25 ft |
| V12 | Depth from feet: acoustic time selects the frame, feet through the homography, nearest-feet-to-acoustic-x attribution, two-camera agreement test | U | Spec 2026-10-30; 95.2 mispair rule feet win beyond 60 in |
| V13 | Continuous gravity-corrected rotation; jolt detection resets anchors; level gate before placement | U | Builds 39, 69, 99.4 |
| V14 | High-resolution still during continuous video, released only when both ankles are behind the baseline | U | 104.9, 2026-11-18 |
| V15 | Device intrinsics instead of a constant focal; stabilization off to recover field | U | Build 92; measured 1557/1399 px against 1300 |

### 1.5 Wearables

| # | Concept | Status | Evidence |
| --- | --- | --- | --- |
| W1 | Wrist shock logger: workout session, 800 Hz batched accelerometer, spike threshold with refractory, events appended and streamed as sensed | U | Builds 73, 93, 95; threshold 3.5 g gave zero spikes 11/09, 2.0 g adopted |
| W2 | Zero-tap launch of the watch app from the phone; heartbeat with workout state; self-healing sensors | U | Build 93, 95; 11/02 double-start failure |
| W3 | Attribution of each acoustic hit to a wearer by nearest spike within a window; strongest spike wins among watches | U | 99.6, 104.2; 18/18 spikes reassigned offline 11/15 |
| W4 | Per-hit 300 ms accelerometer and gyro window streamed as stroke material; gravity vector at impact for forehand/backhand | U | Builds 95, 103 |
| W5 | Watch as time-of-arrival source: known impact instant converts each net mic's TDOA into a range, giving depth and identity together | U (proposed, named as a claim in the spec) | Spec 2026-10-30 §8c |
| W6 | Rally start and stop from the wrist; three-tap readiness check | U | 95, 99.6 |

### 1.6 Speech and the serve ritual

| # | Concept | Status | Evidence |
| --- | --- | --- | --- |
| P1 | Spoken stroke labels paired to the preceding hit, as classifier training data | U | Build 88, 93 review |
| P2 | Own "serving" detector: speech-band burst, MFCC and DTW against the player's own welcome takes, two phones within half a second, own-voice suppression | U | 103.1, 2026-11-14; 56/56 bursts in the scan, word distance 19–22 versus 30 |
| P3 | Serve ritual: word triggers the ranking of four half-baselines by level, cameras confirm feet behind the line, watch names the server, iPad announces; first hit is the serve | U | 99.6–104.10; serve-only confusion-matrix protocol 102.6 |
| P4 | Single announcer; phones silent while armed | U | Build 39 |
| P5 | Score-call recognition from the same detector, extended to digits | N (document 05 F7) | — |

### 1.7 Markers and identity cues

| # | Concept | Status | Evidence |
| --- | --- | --- | --- |
| M1 | Coloured grip band enrolled per session under the day's light; three-cue server identity (pose, colour, score state) | U | Bands memo 2026-11-18; pixel budget 4 × 2 px at 1080p. Enrolment superseded by the reference ring of M8; the three-cue identity stands |
| M2 | Two-tone edge ring sticker: face A and face B colours identify the striking face, hence forehand or backhand with handedness; top mark for orientation | N | Document 07 §1, this document |
| M3 | Fluorescent pigment for the marker; retroreflective stripe lit by the phone torch during the serve still; alternating torch frames for scene subtraction | N | — |
| M4 | Paddle face angle from the projected ring outline at contact | N | — |
| M5 | Impact-triggered optical beacon in the butt cap, confirmed by acoustic coincidence, doubling as a cross-camera sync mark | N | — |
| M6 | NFC fixture tag read on seating; serial parity declares the post; heading check against the stored net orientation | U | Builds 90.1–91 |
| M7 | Ring-coded grip collar: slip-on silicone sleeve on the top of the grip whose identity is the axial sequence of full circumferential rings (two or three rings, four matte colours), so the code reads the same from any rotation of the handle; element width sized to the imaging distance (0.5 in or more for 11 px per inch at the baseline) | N | Document 15 §2; pixel budget document 14 §2 |
| M8 | Integrated colorimetric reference on the sleeve: a white and black ring next to the code rings, used to white-balance and expose-normalise the code in the same image, so the code is read under sun, shade or indoor LED without per-session colour enrolment (replaces the enrolment step of M1) | N | Document 15 §2 item 2 |
| M9 | Metric marker: the known ring widths and collar diameter recover paddle distance and tilt from one still, and paddle speed from consecutive 60 fps frames | N | Document 15 §2–3; depends on build 105 recording |
| M10 | Dual-function collar: a raised lip within the 1.0 in allowance above the top of the grip that is a tactile hand-position index for the player and a silhouette feature for the detector when colour fails (edge-on paddle, poor light) | N | Document 15 §2 item 1 |
| M11 | Rule-shaped placement: the marker as a grip accessory (grip wrap category) with matte finish, no reflective or metallic pigment, colour area limited and placed under or just above the hand; same code printable on an overgrip as the fallback carrier | N | Document 15 §1, §4; USA Pickleball 2.E.5, 2.E.2 |
| M12 | Code-to-name binding and set design: the app reads the code and the player taps a name once per set; sets of four codes differ in every ring so one mis-read colour never maps to another player of the set; manufacturing by over-moulded or two-shot silicone with debossed branding in the body colour | N | Document 15 §2–3, §6 |

### 1.8 Networking and operations

| # | Concept | Status | Evidence |
| --- | --- | --- | --- |
| N1 | QR-rendezvous direct socket over the iPad hotspot with session nonce; multipeer fallback; hotspot gateway address always in the QR; waiting dials kept alive and kicked on join | U | Builds 40, 57, 58; pairing 5–40 s → ~2 s |
| N2 | Wi-Fi Aware as primary link with realtime data path and voice service class; keepalives per TN3213 | U | Build 98, 2026-11-08 |
| N3 | Framed protocol with file streaming, resume offsets, acknowledgement ledger, redundant dual-path sends with receiver dedupe, command and calibration epochs, held critical messages flushed on reconnect | U | Builds 50–74, 93.4 |
| N4 | Truthful liveness heartbeats carrying battery, thermal state, capture stamp; spoken alarms | U | Builds 39, 46, 58 |
| N5 | Idempotent day-folder upload with manifest diff and multipart parts, Wi-Fi only; player self-registration direct to backend with SMS consent | U | Builds 81–83 |
| N6 | External display scene with full-court live view and two-window review | U | Builds 101–102 |

### 1.9 Rally, game and product logic

| # | Concept | Status | Evidence |
| --- | --- | --- | --- |
| R1 | Rally grammar: serve after pause, two-bounce anchor, silence closes the rally | F | July aspect 23 |
| R2 | Explicit session declarations (net orientation, serving half) as the single source of left and right; nothing inferred from slot order | U | Build 39; 66 % → 93 % after correction |
| R3 | Rally mode: qualifying length, clip per confirmed strike from the facing pair, best-camera selection | U | Builds 63, 84, 93b, 97.4 |
| R4 | Side fusion: a person within 48 in of the acoustic x in the taped cameras and none mirrored overrules audio | U | 99.9 |
| R5 | Referee by exception; scripted blocks where the referee taps only deviations | U | 2026-08-07 finding |
| R6 | Rally compilation: hit-by-hit clips from the best camera with a growing court diagram | U (proposed) | Vision doc 2026-11-05 |
| R7 | Pro reference ontology, student matching with synchronized retrieval, outcome-associated sequences, learning loop | N (documents 01–05 F1–F3, F8–F9) | — |
| R8 | Audio-anchored ballistic trajectory fit | N (document 05 F6) | — |

### 1.10 Fixtures

| # | Concept | Status | Evidence |
| --- | --- | --- | --- |
| X1 | Single-sheet, two-part and fold-flat fixtures; horn and baffle; magnetic ring; machine-readable code | F | July claims 17–28 |
| X2 | Bent-aluminium Design B Rev 9 through Rev 10.13 with frozen aim (27° in, 6.5° down), handed parts, sun shade, back-to-back pairs per post with measured mic separation | U | CAD handoff 2026-10-02; runbooks |
| X3 | Fixture serial on every log line and clip; per-fixture camera prior | U | Build 91 |

## 2. Suggested claim families for the new provisional

1. **Self-calibrating acoustic timing network** (S2–S14): iPad-on-T, two-way exchange, ping loop with drift, four-phone symmetric calibration with loop closures, clicker calibration, hybrid re-timing, temperature-corrected speed of sound.
2. **Side-of-net and contact point from two phones per post** (L4–L7, A7): same-post time-difference sum against a measured zero, four-mic solver, hit-versus-landing rules.
3. **Known-geometry camera calibration** (V3–V5, V9–V10, V13–V15): pose-constrained fit with the consistency signal, painted-line and taped-line detectors, four-dot snap, gravity and jolt handling.
4. **Feet-based rule calls and server identification** (V6–V8, V12, R4): ankle homography, sign tests at anchor lines, across-court fault judge, ball-near-wrist, feet-versus-sound arbitration.
5. **Wearable attribution and timing** (W1–W6, S16): streaming shock logger, spike-to-hit matching with clock realignment, per-hit motion windows, watch as time-of-arrival source.
6. **Hands-free serve ritual** (P2–P3, V14, M1, M7–M8, M12): own word detector against enrolled voice takes, feet gate, high-resolution still during video, the band code read from that still and bound to a name, spoken announcement.
7. **Paddle markers** (M2–M5, M7–M12): the ring-coded grip collar with its integrated colour reference and tactile collar, read from any azimuth and used as a metric marker (the lead embodiment, with a design patent on its appearance and a class 28 trademark alongside); two-tone edge ring reporting the striking face, fluorescent and retroreflective materials with torch capture (retroreflective only where the rules allow), face angle from the ring, impact-triggered beacon.
8. **Teaching and strategy layer** (R7–R8, P5): the three families of document 05 plus trajectory fitting and score-call recognition.
9. **Court-side link and data handling** (N1–N5, X3): rendezvous pairing, Wi-Fi Aware, resumable collect, idempotent upload.

Families 1, 2, 5 and 6 have field data. Families 3 and 4 have offline
validation on club photos and one taped-court session. Families 7 and 8 are
conception only and need the pro sessions for examples.

## 3. Reduction-to-practice record

| Date | Venue | Build | Result |
| --- | --- | --- | --- |
| 2026-07-22 | bench | — | Plain cross-correlation beat GCC-PHAT; clocks differed by a stable −7.84 ppm |
| 2026-08-03 | home | 1–4 | Clap and speech session: 50/50 claps kept, zero speech leaks |
| 2026-08-07 | MCC club | 37 | Blind serve card; L/R inversion found (66 % → 93 %); feet truth from photos |
| 2026-08-09 | driveway | 41 | 9/9 serves correct; Δθ repeat +0.40 ms; socket pairing ~2 s |
| 2026-08-10 | MCC club | 45 | 46/46 TDOA on announced serves; 38/38 side calls from automatic homography on one camera; ball median 23 px from wrist |
| 2026-08-14 | Spencer | 57 | Socket pair in 1.0 s after re-scan; pairing root causes closed |
| 2026-08-16/17 | MCC club, offline | 69–70 | Pose fit RMS 1.2–1.4 px; focal 1300 px; lens distortion under 1 px |
| 2026-09-27 | driveway | 74–76 | Distance ladder 216/259/300 in; doublet arrivals; band-pass lifted scores at 216 in from 0.13–0.38 to 0.47–0.58 |
| 2026-10-26 | driveway | 89.1 | Ping-maintained θ: 53 hits rms 4.7 in, all within 15 in; frozen θ rms 21.7 in; hybrid re-timing 5.8 → 4.2 in |
| 2026-10-28 | driveway | 90.2 | Ping drift −6.2 ppm over 31 min; D1 within 1–6 in across 25 min; camera scatter 4 in; one-sided corner bias traced to a phone |
| 2026-11-01/02 | driveway, club | 93–94 | Pink-line fit: two cameras agree on feet to 9 in; white-line fit 12/12 offline |
| 2026-11-07 | driveway | 97.4–97.6 | Four phones: six-pair drift solved, same-post 7.6/7.8 in, 22 four-phone hits all on the correct side, auto clips 18/19/18/19 |
| 2026-11-09/10 | driveway | 99.6–100.2 | Side of net 11/11 acoustic; seven rallies, 56 hits, every side right; audio latency per phone measured |
| 2026-11-14 | driveway | 103.1 | Own word detector after Apple's recognizer failed with Siri disabled |
| 2026-11-16 | regular court | 104.7 | Clicker calibration clean at 7, 13, 22 ft |

## 4. Evidence gaps the pro sessions should close

| Gap | Why it matters | Session block (document 09) |
| --- | --- | --- |
| Regulation painted court with four phones | Every four-phone result is on the taped driveway; the painted-line fit was last validated with two phones | B2, B3 |
| Corner bias and the phone swap | Decides whether the 12 in corner error is a device property; needed to state corner accuracy honestly | B3 |
| Off-net third microphone or camera fusion at the corners | The reports say corners need geometry, not timing | B3 (optional) |
| Serve ritual in real play | The word had not been heard before a serve in any rally as of 102.6; the 104.10 flow is untested | B5 |
| Marker readability | Band pixel size and colour separation unmeasured; the ring-coded collar (M7–M12) exists only as a tape mock-up plan (document 14 §3); hand occlusion of the top of the grip and colour separation after correction on the reference ring are the deciding measurements | B4; 105 driveway run per document 14 |
| Doubles attribution with four watches | Attribution measured with one or two watches, never four | B6 |
| Forehand/backhand from gravity sign | Mechanism built in 103, no labelled validation | B6, B7 |
| Clicker contact depth and ball speed | Unvalidated outputs of 104.7 | B1, B7 |
| Pro reference shots and measured attributes | Families 7 and 8 have no examples at all | B7 |
| Long-session drift on a real court | 90 minute sessions with the ping loop on a painted court | all blocks, by elapsed time |
| iPad off Wi-Fi; collect time | Operational, affects whether sessions yield complete data | B0 |

## 5. Filing notes

- Collect the session reports, pad logs and figures referenced in §3 into
  one evidence folder with dates; several are on the Mac only (the 11/07
  iPad folder, all `.caf` files, the club and lattice folders).
- Keep the invention log current: the marker ideas M2–M5 and the score-call
  recognition P5 originate on 2026-11-19 in this session; the ring-coded grip
  collar M7–M12 also on 2026-11-19 (document 15); the watch time-of-arrival
  concept W5 on 2026-10-31; the bands on 2026-11-17/18.
- Before filing family 7, run a prior-art search on CPC A63B 59/42, A63B 60/08
  to 60/14 (grips) and G06V 20/40 for colour-coded handle markers read by
  cameras; the search of 2026-11-19 found only string-tension and
  grip-position bands (US 7,335,120; US 2018/0065010).
- The July application's statement that near-ultrasonic tones failed
  outdoors is useful background for family 1: the audible chirp, two-way
  exchange and ping loop are the solution to a documented failure.
- The scope review's rule "destructive labels need higher evidence" (faults
  on green only) is a general principle worth claiming across families 2, 4
  and 7.
