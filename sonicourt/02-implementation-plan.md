# 02 — Implementation Plan

Eleven phases, ordered along the critical path. Each phase names its objective,
deliverables, the tests that close it, and a go/no-go gate. Effort estimates
assume one to two experienced engineers plus the user acting as domain expert
and test subject, and they carry wide uncertainty; the gates matter more than
the weeks. Detailed procedures for every test live in `03-test-protocols.md`.

Guiding rules:

- Nothing is built for an application until the foundation phase it depends on
  has passed its gate on real court data.
- Every phase produces annotated data that later phases reuse.
- Offline processing first. On-device processing is deferred until the
  pipeline is correct.

## Phase 0 — Feasibility week (no application code)

Objective: find out, with the cheapest possible experiment, whether the two
riskiest assumptions hold: acoustic separability of events and ball visibility.

Deliverables:

- One recorded session: four phones on tripods using the native camera app,
  1080p60, positioned per the recommended layout, positions surveyed with a
  tape measure. Three hand claps at surveyed positions at the start and end.
  Twenty minutes of dink drill, ten minutes of drives, one full game.
- A Python notebook that aligns the four audio tracks on the claps, plots
  spectrograms around impacts and bounces, and crops the ball from frames at
  near, mid and far court from each camera.
- A one-page findings memo with measured numbers: clap alignment residual,
  impact vs bounce spectral difference, ball pixel size per position, drift
  between first and last clap.

Tests: T0.1 clap alignment, T0.2 acoustic separability by eye, T0.3 ball pixel
budget.

Gate: impacts and bounces are visually separable in spectrograms from at least
three of four phones; ball is at least 6 px from the nearest two cameras at
every court position. If drift between claps exceeds 5 ms, continuous sync
(Phase 1) is confirmed as mandatory rather than optional.

Effort: 1 week.

## Phase 1 — Capture rig and synchronization

Objective: a capture app and procedure that produce a single shared timeline
with sub-millisecond precision across four phones and the watches.

Deliverables:

- iOS capture app: records video and audio with configurable resolution and
  frame rate, logs the host and audio clock at recording start, emits a chirp
  (short linear sweep, e.g. 16–20 kHz, 20 ms) every 10 s on a rotating schedule
  across phones, records a session manifest (device id, position label,
  settings, start time).
- watchOS companion: starts a workout session, streams or stores accelerometer
  and gyroscope at the highest available rate with device timestamps, tags
  samples with wearer id.
- Sync service (offline, Python): detects chirps in every track, solves per-phone
  offset and drift (linear model, re-estimated every chirp), computes pairwise
  inter-phone distances from round-trip chirps, outputs a timeline map from each
  device clock to master time.
- Session manifest format and folder layout (`04-data-model.md`, section 6).

Tests: T1.1 chirp detection reliability, T1.2 sync residual with surveyed
claps, T1.3 drift over 90 min, T1.4 self-ranging vs tape measure, T1.5 watch
timestamp continuity.

Gate: sync residual < 0.5 ms across the session; self-ranged distances within
5 cm of tape measure; watch data with no gaps > 50 ms during a 60-minute
session; app records 90 minutes on external power without thermal shutdown.

Effort: 3–4 weeks.

## Phase 2 — Court and camera calibration

Objective: map every camera pixel to court coordinates on the ground plane and
recover full camera geometry for triangulation.

Deliverables:

- Court line detector (classical edge and Hough or a small segmentation model)
  that finds baselines, sidelines, kitchen lines, centre lines and net posts.
- Per-camera homography (ground plane) and full intrinsic/extrinsic calibration
  from the known 3D positions of court points, including the off-plane net
  post tops and net centre.
- Automatic recalibration check: reprojection error of court lines computed
  every N seconds; alert when a camera has moved.
- Court coordinate convention (origin, axes, units) fixed in `04-data-model.md`.

Tests: T2.1 marker reprojection, T2.2 cross-camera consistency of a walked
path, T2.3 off-plane accuracy using net-post tops and a marked pole.

Gate: ground-plane error < 10 cm anywhere on the court from the nearest
camera; cross-camera foot-position disagreement < 20 cm; off-plane point
error < 5 cm at net height.

Effort: 2–3 weeks.

## Phase 3 — Acoustic event detection and localization

Objective: a detector that turns four audio tracks into a list of timed,
typed, coarsely localized events and rejects everything not on this court.

Deliverables:

- Onset detector plus classifier (paddle impact / ball bounce / net contact /
  other) on mel-spectrogram windows. Start with a small CNN or gradient-boosted
  features; both are fine at this data size.
- Multi-phone event association: the same physical event appears on four tracks
  at four times; associate by consistent propagation delays.
- Time-difference-of-arrival localization with the calibrated phone geometry;
  output position and covariance.
- Court gating: events localized outside a margin around the court are dropped
  and logged.
- Annotation tool v1: waveform and spectrogram view with video scrub, hotkeys
  for event type, export to the event schema.

Tests: T3.1 detection precision and recall vs golden set, T3.2 timing
precision vs video-derived contact frame, T3.3 localization vs video bounce
location, T3.4 adjacent-court rejection.

Gate: impact recall and precision both ≥ 95%; bounce recall ≥ 90%; event
timing within 2 ms of the best manual estimate; localization median error <
50 cm; ≥ 95% of adjacent-court events rejected.

Effort: 3–4 weeks. Data collection for this phase starts in Phase 0.

## Phase 4 — Ball detection and trajectory reconstruction

Objective: for each flight segment between two acoustic events, a 3D
trajectory with launch velocity, apex, net clearance and bounce location.

Deliverables:

- Ball detector per camera (fine-tune a small object detector on pickleball
  frames; use two-frame difference input to exploit motion). Bootstrap labels
  by projecting the physics fit back into frames once the loop closes.
- Multi-view association and triangulation with the Phase 2 calibration.
- Physics fit: parabola with quadratic drag, unknowns are launch position and
  velocity, boundary times fixed by audio, observations are triangulated or
  single-view rays. Outputs a covariance so downstream code knows when a fit is
  weak.
- Derived measures: speed at contact, direction, contact height, net clearance,
  bounce location, in/out with margin, time of flight.

Tests: T4.1 speed vs radar gun, T4.2 net clearance vs physical string gauge,
T4.3 bounce vs marked landing spots, T4.4 contact height vs marked drop tests,
T4.5 fit robustness with occluded contact.

Gate: speed within 5% of radar for drives and serves; net clearance within
5 cm; bounce within 15 cm; contact height within 8 cm; ≥ 90% of flights in a
game receive a fit with acceptable covariance.

Effort: 6–8 weeks. This is the longest foundational phase.

## Phase 5 — Player tracking, identity and wearable fusion

Objective: every impact is attributed to a named player with side (forehand /
backhand), and player positions are known at every event.

Deliverables:

- Pose estimation per camera (an off-the-shelf multi-person pose model), foot
  keypoints mapped to court coordinates through the homography, multi-camera
  fusion into one track per person.
- Wearable impact detector (acceleration magnitude spike) and matcher against
  the acoustic impact train: solves watch clock offset and attributes impacts.
- Fallback attribution without watches: nearest tracked player to the
  localized impact on the correct side of the net.
- Forehand / backhand from pose (paddle-arm keypoint relative to shoulder line
  and body facing) combined with wearable gyroscope sign.
- Player registry: names, dominant hand, watch id, appearance embedding for
  re-identification across sessions.

Tests: T5.1 attribution accuracy with watches, T5.2 without watches, T5.3
forehand/backhand accuracy, T5.4 position accuracy at contact.

Gate: attribution ≥ 98% with watches, ≥ 90% without; forehand/backhand ≥ 95%;
player position at contact within 30 cm.

Effort: 4–6 weeks. Can run in parallel with Phase 4 once Phase 3 has passed.

## Phase 6 — Shot reconstruction and ontology classification

Objective: convert events into shot records with base type, attributes and
context-derived labels, following `04-data-model.md`.

Deliverables:

- Shot assembler: pairs each impact with the flight and bounce that follow it,
  attaches player, position, side and measures.
- Rule-based base-type classifier over measured features (speed, contact
  height, launch angle, bounce location, whether the ball bounced before
  contact, player position relative to the kitchen line). Rules are versioned
  and human-readable.
- Attribute derivation (crosscourt / straight, offensive / defensive by speed
  and bounce depth, spin as a placeholder until measurable).
- Context labels from rally state: third-shot drop / drive, dink → speed-up,
  reset, counter, put-away.
- Annotation tool v2: shot-level labels by the pro, with disagreement review.
- Learned classifier trained on rule labels corrected by the pro, evaluated
  against held-out pro labels.

Tests: T6.1 inter-annotator agreement baseline, T6.2 rule classifier vs pro
labels, T6.3 learned classifier vs pro labels, T6.4 context label correctness.

Gate: base-type agreement with the pro ≥ 90% on shots the pro labels
confidently, with the classifier at or above the measured human-human
agreement; context labels ≥ 95% correct given correct base types.

Effort: 4–5 weeks.

## Phase 7 — Rally segmentation, outcome and scoring

Objective: shots are grouped into rallies with a winner, and the score is
tracked.

Deliverables:

- Rally segmenter: a serve is the first impact after a pause, from behind a
  baseline, by the player the score call names; a rally ends at an out bounce,
  net contact without crossing, double bounce, missed ball, or an inactivity
  timeout.
- Outcome rules with an error taxonomy (net, out, double bounce, whiff, fault)
  and forced / unforced heuristics based on incoming ball speed and player
  distance to contact.
- Score-call speech recognition: a small vocabulary recognizer on the P1/P2
  audio for "X-Y-Z" calls; reconciliation with event-derived outcomes; flags
  disagreements for review.
- Game and session records.

Tests: T7.1 rally boundary accuracy, T7.2 outcome accuracy, T7.3 score-call
recognition accuracy, T7.4 reconciliation rate.

Gate: rally boundaries ≥ 98% correct; winner ≥ 97% correct; score call
recognized ≥ 90% of the time with < 1% wrong recognitions; every disagreement
surfaced for review.

Effort: 3–4 weeks.

## Phase 8 — Application A: teaching and shot comparison

Objective: the pro records references, the student's matching attempts are
found automatically, and the iPad shows synchronized comparisons with
quantitative deltas.

Deliverables:

- Reference capture mode: pro selects the shot class, performs N repetitions,
  system builds the template (per-measure mean, spread and the pro's chosen
  exemplar).
- Matching: student shots with the same base type and attributes are linked to
  the reference class; within class, similarity ranking on the pro-selected
  measures.
- Comparison renderer: clips from the same relative camera position, aligned at
  impact time, court-normalized overlay, trajectory diagram, measure table with
  deltas, slow motion and frame stepping.
- Auto-retrieval: on shot completion, show the last attempt, the student's best
  attempt by the pro's success criterion, and the pro reference.
- iPad app (SwiftUI) talking to a local or cloud API; a session review web page
  for the student.

Tests: T8.1 matching precision and recall, T8.2 alignment accuracy, T8.3 pro
usability sessions, T8.4 end-to-end latency from shot to retrieval.

Gate: matching ≥ 95% on the dink and drop classes; alignment error at impact
< 1 frame; the pro completes a 30-minute lesson using the tool without
searching video manually; retrieval latency acceptable to the pro (target
under 10 s in offline mode, near-real-time later).

Effort: 6–8 weeks. The first vertical slice (dinks only) can ship in 3–4 weeks
after Phase 6.

## Phase 9 — Application B: longitudinal analysis

Objective: individual and partnership statistics with confidence intervals
over a growing rally database.

Deliverables:

- Analytics store (a columnar database over the shot and rally tables) and a
  statistics library implementing every metric in the concept write-up, each
  with a written definition and a confidence interval.
- Conditioning dimensions: side, court zone, rally index, opponent, partner,
  session date range.
- Partnership analysis: outcome and pattern metrics per pairing, compared
  against each player's overall rates with shrinkage toward the baseline.
- Reports and a dashboard.

Tests: T9.1 metric reconciliation against manual counts, T9.2 interval
calibration on resampled data, T9.3 partnership metric sanity.

Gate: every metric reconciles with manual counts on three games; intervals
are honest under bootstrap resampling.

Effort: 3–4 weeks.

## Phase 10 — Application C: winning and losing patterns

Objective: outcome-associated sequences discovered, validated, ranked and
linked to video.

Deliverables:

- Rally tokenizer with abstraction levels (player-specific, side-specific,
  type-only) and positional state tokens (transition zone, at kitchen).
- Sequence mining (n-grams and a prefix-based frequent-sequence miner) with
  minimum support.
- Association scoring: win rate per pattern with Wilson intervals, shrinkage
  toward the team baseline, multiple-comparison control, and a plain-language
  rendering.
- Retrieval: every pattern links to its supporting rallies, events and clips.
- Query interface for the instructor requests in the concept write-up.
- Learning loop: for a targeted pattern and player, frequency and outcome
  before and after a marked instruction date.

Tests: T10.1 recovery of seeded synthetic patterns, T10.2 holdout stability,
T10.3 instructor relevance rating, T10.4 query correctness.

Gate: seeded patterns recovered at ≥ 90% with false discoveries under control;
patterns found on the first half of the data replicate on the second half at a
rate consistent with their reported intervals; instructor rates a majority of
top-ten patterns as actionable.

Effort: 4–6 weeks.

## Phase 11 — Hardening and on-device migration (optional)

Objective: reduce processing latency and operational friction for routine use.

Candidates: on-device event detection for live feedback during lessons,
automatic upload and processing, multi-court venue support, non-Apple wearables.
Only planned once Applications A–C are in weekly use.

## Timeline summary

| Phase | Weeks | Depends on |
| --- | --- | --- |
| 0 Feasibility | 1 | — |
| 1 Capture and sync | 3–4 | 0 |
| 2 Calibration | 2–3 | 1 |
| 3 Acoustic events | 3–4 | 1 |
| 4 Ball trajectory | 6–8 | 2, 3 |
| 5 Identity and wearables | 4–6 | 3 (parallel with 4) |
| 6 Shots and ontology | 4–5 | 4, 5 |
| 7 Rallies and outcomes | 3–4 | 6 |
| 8 App A | 6–8 | 6 (dink slice), 7 (full) |
| 9 App B | 3–4 | 7 |
| 10 App C | 4–6 | 9 |

Sequential worst case is about twelve months. With Phases 4 and 5 in parallel
and the dink slice of App A started as soon as Phase 6 handles dinks, a usable
teaching tool is realistic in four to five months and Application C in nine to
ten.

## Recommended tooling

- Capture: Swift, AVFoundation, WatchConnectivity, HealthKit workout session.
- Pipeline: Python with NumPy, SciPy, OpenCV, PyTorch; librosa or torchaudio
  for audio features; an off-the-shelf detector family for ball and pose; a
  small-vocabulary speech model for score calls.
- Storage: files for media, Parquet for events and derivations, DuckDB or
  PostgreSQL for the analytics store.
- Applications: SwiftUI on iPad; a lightweight web dashboard for B and C.
