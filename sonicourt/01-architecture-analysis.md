# 01 — Architecture Analysis

This document examines the Sonicourt concept write-up as an engineering
proposal: what is well founded, what is assumed without being stated, which
problems are hard, and which design decisions should be locked in before
building.

## 1. What the concept gets right

**Audio as the timing backbone.** A paddle impact is a transient of roughly one
millisecond. At 48 kHz sampling, its onset can be located to well under a
millisecond. Video at 60 fps has a frame interval of 16.7 ms and cannot say when
contact happened, only which frame it is near. Using audio to timestamp every
impact and bounce, and then treating each ball flight as a segment between two
precisely known instants, turns trajectory reconstruction from a hard tracking
problem into a well-constrained physics fit. This is the single most valuable
idea in the write-up and the plan is built around it.

**Fusion over a single model.** No single sensor has to solve everything. Audio
owns timing and coarse localization, video owns geometry and semantics, the
wearable owns identity and stroke motion. Each has an independent failure mode,
so the fused result degrades gracefully.

**Preserving observations under a versioned hierarchy.** Storing raw events and
deriving shots, rallies and patterns from them means every future improvement in
classification can be re-run over history. This is the correct storage
architecture and should be treated as non-negotiable.

**Base types plus attributes plus context.** Twelve base shot types with
attributes and context-derived labels avoids the combinatorial explosion of
trying to learn "third-shot backhand crosscourt topspin drop" as its own class.
It also means most "sophisticated" shot labels are deterministic functions of
measured quantities and rally state rather than learned categories.

**The pro defines the reference.** Declining to encode a single "correct"
technique keeps the system a measurement tool rather than an opinion, which is
both pedagogically right and easier to build.

**Player-specific patterns.** Presenting patterns as findings about these four
players rather than universal strategy is both more honest statistically and
more useful to an instructor.

## 2. Hidden assumptions and hard problems, ranked by risk

### R1. Cross-device clock synchronization (highest risk, foundational)

Everything downstream assumes the four phones share a timeline. They do not.
(The prototype has solved this for two phones with iPad-on-T chirp calibration;
see document 06 §2.2 for what remains.)

| Quantity | Value | Consequence |
| --- | --- | --- |
| Speed of sound | ~343 m/s | 1 ms timing error = 34 cm localization error |
| Target localization precision | 10–20 cm | Needs ~0.3–0.6 ms combined timing precision |
| Typical crystal drift between phones | ±20 ppm | ~1.2 ms per minute, ~100 ms over a 90-minute session |
| Audio clock vs system clock on one phone | independent | Sample-count time and wall-clock time diverge |
| Network time (NTP) accuracy on phones | 10–100 ms | Useless for acoustic localization, marginal even for frame alignment |

A one-time clap at the start of a session is therefore not enough. The plan
uses continuous acoustic synchronization: one phone emits a short chirp every
ten seconds; because phone positions are known, every other phone can compute
the expected propagation delay and correct its offset and drift continuously.
The same chirps, emitted in turn by each phone, yield pairwise inter-phone
distances without any clock synchronization at all (the round-trip "BeepBeep"
method), which self-calibrates the microphone array geometry.

Gate before proceeding: residual timing error between phones under 0.5 ms for
the whole session, verified with claps at surveyed positions.

### R2. Ball visibility from phone cameras (high risk)

The court is 13.41 m long and 6.10 m wide. The ball is about 7.4 cm across.

Rough pixel budget for a phone behind a baseline, 3 m back, 1080p, ~70° field
of view:

| Ball location | Distance from camera | Metres per pixel | Ball size |
| --- | --- | --- | --- |
| Near kitchen line | ~8 m | ~0.6 cm | ~12 px |
| Far kitchen line | ~12 m | ~0.9 cm | ~8 px |
| Far baseline | ~17 m | ~1.2 cm | ~6 px |

At 4K the same numbers double. Motion blur adds to this: a 22 m/s drive with a
1/120 s shutter smears 18 cm, several ball diameters. Far-court detection from a
baseline phone is marginal at 1080p and acceptable at 4K. Side phones near the
net see every point of the court within ~10 m, which is why the recommended
layout includes them.

Mitigations, in order of preference: rely on the two nearest cameras for each
half of the court, use the audio-anchored physics fit so that only a handful of
detections per flight are needed, record 4K where thermal and storage limits
allow, and consider a fifth device (or a dedicated action camera) only if tests
demand it.

### R3. Adjacent-court contamination (high risk in real venues)

Most pickleball happens at multi-court facilities. Neighbouring courts produce
impacts and bounces with the same acoustic signature and can appear in the
background of video. This is the strongest practical argument for acoustic
localization: an event whose time-difference-of-arrival solution falls outside
the instrumented court is rejected before it enters the timeline. Video-based
court masking handles the visual side.

### R4. Player identity (medium risk with wearables, high without)

Appearance-based tracking drifts across occlusions and partner swaps. The
wearable gives a much stronger signal: a paddle impact produces a sharp
acceleration spike on the wrist. Matching the watch's spike train to the audio
impact train gives, in a single operation, the watch-to-phone clock offset and
the attribution of each impact to a wearer. With two watches per team, the
attribution problem for doubles is essentially solved; with one watch per
player it is solved outright. The plan treats "no wearable" as a degraded mode
that uses court-side heuristics (which side of the net the impact localized to,
which tracked person was closest to the ball) and accepts lower accuracy.

Note on Apple Watch sensor rates: standard Core Motion delivers about 100 Hz
during a workout session. Newer watches expose higher-rate batched accelerometer
data (verify current watchOS limits during Phase 1). 100 Hz is enough to detect
impact spikes to ±10 ms, which is sufficient for matching against audio events
that are typically hundreds of milliseconds apart.

### R5. Three-dimensional reconstruction and occlusion (medium risk)

Bounce locations and player positions live on the ground plane and can be
recovered from a single camera with a court-line homography. Contact height,
net clearance and trajectory are off-plane and need either two views or the
physics fit. Players occlude the ball near contact, which is precisely where
contact height matters. The physics fit resolves this: the contact point is the
start of a parabola whose later points are visible, and its time is known from
audio.

### R6. Ground-truth cost (medium risk, chronic)

Every accuracy claim in this plan requires annotated data. The write-up does not
mention annotation. The plan budgets a "golden set" from the start and treats
annotation tooling as a first-class deliverable. The pro's own labels during
Application A are also a labeling source and should be captured as such.

### R7. Statistical power for pattern discovery (medium risk)

A game to 11 has roughly 20–25 rallies. One hundred games therefore give about
2,000–2,500 rallies. Sequences of four player-specific shots are sparse at that
size. Application C needs a token hierarchy (player-specific → side → shot type)
so that patterns can be found at whichever abstraction level has support, and it
must report confidence intervals, not point estimates.

### R8. Thermal, storage and battery for 90-minute sessions (low-medium risk)

Approximate HEVC storage per phone: 1080p60 ≈ 90 MB/min (8 GB per 90 min);
4K30 ≈ 190 MB/min; 4K60 ≈ 400 MB/min (36 GB per 90 min). Phones recording 4K
outdoors in the sun throttle. Plan for external power, shade, and 1080p60 as
the default until tests show 4K is needed on specific positions.

### R9. Consent and privacy (low technical risk, must be designed in)

The system records identifiable people, including opponents and bystanders,
and stores movement data. Session-level consent, face-region handling for
non-participants, and per-player data ownership need a policy before the first
group session. This also matters for patent timing (see `05-invention-concepts.md`).

## 3. Design decisions to lock in

| # | Decision | Rationale |
| --- | --- | --- |
| D1 | Offline-first pipeline. Phones capture; a Mac or cloud job processes. | Removes on-device compute and app-store constraints from the critical path. On-device processing is a later optimization. |
| D2 | A minimal custom capture app rather than the native camera. | Needed for chirp emission, timestamp logging, Watch pairing and consistent settings. Week 1 experiments still use the native app. |
| D3 | Audio is the master timeline; video frames and wearable samples are mapped onto it. | Audio has the best timing precision and every sensor can be aligned to acoustic events. |
| D4 | Continuous chirp-based synchronization and self-ranging of the phone array. | Solves R1 and gives inter-phone distances for free. |
| D5 | Camera calibration from court geometry only. | Court lines, kitchen lines and net posts are known 3D points. No checkerboards on court. |
| D6 | Trajectory is a physics fit between audio-anchored events; visual detections are observations, not the primary signal. | Solves R2 and R5 with far fewer detections. |
| D7 | Wearable impact spikes matched to audio impacts for identity and watch clock sync. | Solves R4 with one mechanism. |
| D8 | Rule-based shot classifier first, learned classifier second. | Rules grounded in measured physics are auditable and produce training labels for the learned version. |
| D9 | Event-sourced storage; every derived layer carries the version of the code that produced it. | Enables reclassification of history, which the write-up correctly identifies as a core advantage. |
| D10 | Score-call speech recognition as a free ground-truth channel. | Players announce the score before every serve. Recognizing "4-2-1" gives the score, the serving team, and the server number, and lets the system self-check rally outcomes. |

## 4. Recommended physical layout

> Superseded by `06-reconciliation-with-sonicourt-app.md` §2.1. The existing
> prototype mounts phones on the net posts in a fixed bracket, which gives a
> better pixel budget for the ball and an edge-on view of the net tape. The
> four-phone form is two phones per post, one facing each half. The layout
> below is retained as the alternative if bounce-depth accuracy fails its gate.

Court: 6.10 m × 13.41 m. Non-volley zone 2.13 m from the net on each side. Net
0.914 m at the posts and 0.864 m at centre.

| Device | Position | Height | Primary role |
| --- | --- | --- | --- |
| P1 | Behind baseline A, on the centre line, 2.5–3 m back | 2.5–3 m, tilted down | Ground-plane view of far half, player positions, bounce locations on side B |
| P2 | Behind baseline B, mirrored | 2.5–3 m | Same for side A |
| P3 | Sideline, level with the net, 2–3 m outside | ~1.0–1.2 m (net height) | Net clearance, contact height, full-court ball tracking at short range |
| P4 | Opposite sideline, level with the net | 2.5–3 m | Elevated side view for trajectory triangulation with P3 |
| Watches | Paddle wrist of each player | — | Impact spikes, identity, stroke motion |

Phone positions are surveyed once with a tape measure relative to court
corners, then refined by the chirp self-ranging. Mounts need to be rigid: any
camera movement after calibration invalidates the extrinsics, so calibration
should be re-verified from court lines every few minutes automatically.

## 5. Sensor budget

Which sensor is the primary source for each quantity, and which corroborates it.

| Quantity | Primary | Corroborating |
| --- | --- | --- |
| Event time | Audio | Wearable (impacts), video (bounce frame) |
| Event type (impact / bounce / net / other) | Audio classifier | Video (ball near paddle vs ground vs net), wearable (impact only) |
| Event court coordinates | Video homography (bounce), triangulation (contact) | Acoustic TDOA (coarse, for gating) |
| Player identity | Wearable spike matching | Appearance re-identification, court side |
| Forehand / backhand | Pose (paddle arm vs body orientation) | Wearable gyroscope pattern |
| Player position | Pose foot keypoints via homography | — |
| Paddle motion | Wearable accelerometer and gyroscope | Pose wrist trajectory |
| Ball speed and direction | Physics fit anchored on audio times | Visual detections |
| Trajectory, net clearance, contact height | Physics fit + triangulation | Side camera at net height |
| Bounce location | Homography from nearest camera | Audio TDOA, physics fit |
| In / out | Bounce location vs court lines | — |
| Rally outcome | Event sequence rules | Score-call speech recognition |
