# 03 — Test Protocols

Concrete procedures for the tests referenced in `02-implementation-plan.md`.
Each protocol states equipment, procedure, ground truth, metric and pass
criterion. Protocols are numbered by phase.

## 0. Shared conventions

- **Court frame.** Use the prototype's net-centred frame (see document 06
  §2.1 and `04-data-model.md` §1). Metric values in this document are
  tolerances, not coordinates.
- **Existing practice.** The prototype's printed serve cards, blind blocks,
  photo-verified feet truth, BLOCK markers in the pad log and three-way
  cross-check (card, referee taps, log) are the established truth method and
  apply to every protocol below.
- **Survey.** Phone positions and every marker are measured with a laser
  distance meter or steel tape from two court corners and recorded in the
  session manifest before recording starts.
- **Golden set.** A manually annotated collection of sessions that grows through
  the project. Every test that says "vs golden set" uses only sessions not used
  for training or rule tuning.
- **Annotation protocol.** Two annotators label event times, event types and
  shot types independently on the same segment; disagreements are resolved by
  the pro. Agreement rates are recorded because they bound achievable accuracy.

## 1. Datasets to collect

| Id | Content | Purpose | Duration |
| --- | --- | --- | --- |
| D0 | Claps and chirps at surveyed positions, quiet court | Sync, ranging, localization | 10 min |
| D1 | Static markers (cones, tape crosses) at 20 surveyed court points | Camera calibration | 5 min |
| D2 | Ball drops from measured heights at marked spots; balls rolled to a stop at marked spots | Contact height, bounce location, bounce acoustics | 15 min |
| D3 | Dink drill, crosscourt and straight, both sides, both players | App A slice, slow ball tracking | 20 min per session |
| D4 | Drive and serve drill with radar gun readings called aloud | Speed validation | 15 min |
| D5 | Net clearance drill with a string gauge above the net (see T4.2) | Clearance validation | 15 min |
| D6 | Full games with score calls, four players, all three pairings | Everything downstream | 3+ games per session |
| D7 | Recording with an active adjacent court | Contamination rejection | 20 min |
| D8 | Pro reference library, 20 repetitions per class | App A | 60 min |

Aim for at least ten D6 sessions with the recurring group before Application C
work starts; that is roughly 30 games and 600–750 rallies.

## Phase 0

**T0.1 Clap alignment.** Three claps at surveyed positions at the start and at
the end. Align tracks by cross-correlation around each clap after subtracting
the expected propagation delay from the surveyed positions. Metric: residual
after alignment; drift between first and last clap. Pass: residual < 2 ms;
drift reported.

**T0.2 Acoustic separability.** Plot mel-spectrograms around 30 impacts and 30
bounces from the dink drill. Pass: an annotator can sort them by eye with ≥ 90%
accuracy on every phone that is within 10 m of the events.

**T0.3 Ball pixel budget.** Crop the ball at nine positions (near, mid, far ×
left, centre, right) from each camera. Pass: ≥ 6 px from the nearest two
cameras at every position.

## Phase 1

**T1.1 Chirp detection.** Run the sync service on a 90-minute session. Metric:
fraction of scheduled chirps detected on every other phone. Pass: ≥ 99%.

**T1.2 Sync residual.** Twelve claps at four surveyed positions spread through a
session. For each clap and phone pair, compare measured arrival-time difference
to the difference predicted from the survey. Metric: median and 95th percentile
absolute residual. Pass: 95th percentile < 0.5 ms.

**T1.3 Drift.** Same as T1.2 but report residual as a function of time since
session start with the chirp correction on and off. Pass: no trend with
correction on.

**T1.4 Self-ranging.** Compare the six pairwise distances from round-trip chirps
with the surveyed distances. Pass: all within 5 cm.

**T1.5 Watch continuity.** Sixty-minute recording on two watches. Metric:
largest gap between consecutive samples, sample-rate stability, battery drain.
Pass: no gap > 50 ms; battery drain acceptable for a two-hour session.

**T1.6 Thermal and storage.** Ninety-minute recording on external power in the
warmest expected conditions. Pass: no throttling below the configured frame
rate, no stops.

## Phase 2

**T2.1 Marker reprojection.** Twenty markers (D1). Project surveyed coordinates
through each camera's calibration; measure pixel error, and invert to measure
court-plane error. Pass: ground-plane error < 10 cm from the nearest camera,
< 20 cm from any camera that sees the point.

**T2.2 Walked path.** A person walks the court lines. Foot keypoints from each
camera are mapped to court coordinates. Metric: disagreement between cameras
and distance to the known line. Pass: cross-camera disagreement < 20 cm.

**T2.3 Off-plane accuracy.** Net-post tops, net centre and a pole with tape
marks at 0.5 m, 1.0 m and 1.5 m placed at five court positions. Triangulate
from camera pairs. Pass: < 5 cm at net height, < 8 cm at 1.5 m.

**T2.4 Movement detection.** Nudge one tripod by 1 cm mid-session. Pass: the
recalibration check flags the camera within one check interval.

## Phase 3

**T3.1 Detection.** Golden-set sessions. Metric: precision and recall per
event type, matched within a 10 ms window. Pass: impact ≥ 95% / ≥ 95%; bounce
recall ≥ 90%; net contact recall ≥ 80%.

**T3.2 Timing.** For 100 impacts, compare detector time to the best manual
estimate from the waveform. Pass: 95% within 2 ms.

**T3.3 Localization.** For 100 bounces with video-derived locations (T2
calibration), compare the acoustic solution. Pass: median < 50 cm; 90% inside
the court boundary plus a 1 m margin.

**T3.4 Adjacent-court rejection.** D7. Annotators mark which events belong to
the instrumented court. Pass: ≥ 95% of foreign events rejected; ≤ 2% of own
events rejected.

## Phase 4

**T4.1 Speed.** D4 with a radar gun. Compare the fit's speed at contact to the
radar reading for 50 drives and 30 serves. Pass: 90% within 5%.

**T4.2 Net clearance.** String gauge: a horizontal string above the net at
measured heights (10 cm, 20 cm, 40 cm) for a dink and drop drill; the annotator
notes whether each ball passed above or below the string from a side camera
frame. Compare with the fit's clearance. Pass: sign correct 95% of the time
and, for balls within 5 cm of the string, the fit's estimate within 5 cm.

**T4.3 Bounce location.** D2 drops and D3 dinks with landing spots marked from
a high side camera or by dusting balls with chalk. Pass: 90% within 15 cm.

**T4.4 Contact height.** D2 drops from measured heights (ball released at a
marked height, first bounce is the "contact"). Pass: 90% within 8 cm.

**T4.5 Occluded contact.** Select 50 flights where the ball is invisible in the
first 100 ms after contact. Pass: fit quality and error no worse than T4.1–T4.4
by more than 50% relative.

**T4.6 Coverage.** Full game. Pass: ≥ 90% of flights fit with covariance under
the threshold set in Phase 4.

## Phase 5

**T5.1 Attribution with watches.** Full game, all four players with watches.
Pass: ≥ 98% of impacts attributed to the correct player.

**T5.2 Attribution without watches.** Same game with watch data withheld. Pass:
≥ 90%.

**T5.3 Forehand / backhand.** Golden-set labels. Pass: ≥ 95%.

**T5.4 Position at contact.** Compare fused position to the nearest camera's
homography reading and to annotator judgement on ambiguous cases. Pass: within
30 cm.

**T5.5 Cross-session re-identification.** Two sessions on different days.
Pass: players recognised without manual assignment, or a single confirmation
per session.

## Phase 6

**T6.1 Inter-annotator agreement.** Two annotators, 300 shots. Report agreement
per base type. This is the ceiling for T6.2 and T6.3.

**T6.2 Rule classifier.** Held-out pro labels, 500 shots. Pass: ≥ 90% base-type
agreement on confident labels; confusion matrix reviewed with the pro.

**T6.3 Learned classifier.** Same set. Pass: at or above T6.2 and at or above
T6.1 agreement.

**T6.4 Context labels.** Given correct base types, check third-shot labels,
speed-up, reset, counter and put-away against annotators. Pass: ≥ 95%.

## Phase 7

**T7.1 Rally boundaries.** Three games. Pass: ≥ 98% of rallies start and end at
the annotated events.

**T7.2 Outcome.** Pass: winner ≥ 97%; error type ≥ 90%.

**T7.3 Score-call recognition.** Pass: ≥ 90% of calls recognised; wrong
recognitions < 1%.

**T7.4 Reconciliation.** Every disagreement between event-derived outcome and
score-call progression is listed. Pass: 100% surfaced; after review, residual
system error ≤ 2%.

## Phase 8

**T8.1 Matching.** Pro labels every student dink and drop in a lesson. Pass:
≥ 95% precision and recall for assignment to the reference class.

**T8.2 Alignment.** Fifty comparison pairs. Pass: impact frame difference < 1
frame in every case.

**T8.3 Pro usability.** Three 30-minute lessons. Record every time the pro
searches video manually and every retrieval that was wrong. Pass: no manual
searches in the third lesson; the pro would use it again.

**T8.4 Latency.** Time from shot to retrieval on screen. Pass: under 10 s in the
offline pipeline; target set for later phases.

## Phase 9

**T9.1 Reconciliation.** Manual counts for every metric on three games. Pass:
exact agreement or a documented definitional difference.

**T9.2 Interval calibration.** Bootstrap resampling of rallies. Pass: reported
95% intervals cover the resampled value about 95% of the time.

**T9.3 Partnership sanity.** With fewer than 30 rallies for a pairing, the
partnership metric must be reported as insufficient rather than as a number.

## Phase 10

**T10.1 Seeded patterns.** Generate synthetic rally databases with known
planted sequences and win-rate effects at realistic sizes (600, 1,500 and 3,000
rallies). Pass: ≥ 90% of planted patterns recovered at the size where they are
statistically detectable; false discoveries controlled at the configured rate.

**T10.2 Holdout stability.** Split the real database by date. Pass: patterns
ranked in the top ten on the first half show effects on the second half within
their reported intervals at the expected rate.

**T10.3 Instructor relevance.** The pro rates the top ten patterns for each
player as actionable, obvious, or noise. Pass: majority actionable; every
pattern's retrieved examples judged representative.

**T10.4 Query correctness.** The four example queries from the concept
write-up run against the database; results checked against annotators. Pass:
≥ 95% precision and recall.

**T10.5 Learning loop.** One targeted pattern per player, instruction date
recorded. Pass: the before/after report is produced with honest intervals; the
system makes no claim when the sample is too small.
