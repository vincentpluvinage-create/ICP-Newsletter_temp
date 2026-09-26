# 05 — Invention Concepts

This note separates the potentially distinct inventive concepts exposed by the
Sonicourt concept and by the engineering plan, so they can be evaluated as
separate claim families rather than buried in one system description. It is an
engineering view, not legal advice; a patent attorney should assess novelty,
prior art and claim strategy.

## 1. The three families identified in the write-up

### F1. Personalized shot ontology from multimodal reference demonstrations

A teaching professional demonstrates shots; the system records synchronized
audio, multi-camera video and wearable motion; from these it derives a
quantitative template per shot class (contact position, paddle motion, ball
launch, trajectory, net clearance, bounce) and stores it as a reference layer
over a universal ontology. Distinguishing features: the reference is
multimodal and quantitative, the professional defines which measurements are
pedagogically relevant, and multiple ontology levels (universal, professional,
player, group) coexist over the same stored events.

### F2. Automatic matching of student execution to professional reference with synchronized comparative retrieval

Student shots are classified with the same ontology, matched to the reference
class, and the system retrieves and time-aligns (at audio-precise impact) the
student attempt, a representative successful attempt by the same student, and
the professional reference, presenting them side-by-side, overlaid or
sequentially with quantitative deltas. Distinguishing features: the alignment
instant comes from acoustic impact timing; retrieval is automatic on shot
completion; comparison is in a common court-normalized frame.

### F3. Discovery of outcome-associated rally sequences with automatic retrieval of underlying video

Rallies are encoded as token sequences at multiple abstraction levels; frequent
subsequences are mined and associated with outcomes with statistical
confidence; each discovered pattern is linked back to the rallies, events and
video segments that support it, so an instructor can retrieve the actual
examples. Distinguishing features: player-specific rather than universal
patterns, multi-level abstraction to handle sparse data, and the closed loop
that measures behaviour and outcome change after instruction.

## 2. Additional candidates exposed by the engineering plan

### F4. Wearable-to-acoustic impact matching for player attribution and clock synchronization

Matching the acceleration spike train from a wrist-worn device against the
acoustic paddle-impact train yields the device clock offset and the attribution
of each impact to a wearer in one operation. This is a specific mechanism with a
clear technical effect (identity without visual re-identification) and may be
claimable independently of the teaching applications.

### F5. Self-synchronizing, self-ranging acoustic phone array bound to court geometry

Periodic chirps between phones at known positions provide continuous clock
correction and inter-phone distances; the array is anchored to the court
through camera calibration from court lines; events localized outside the court
are rejected. Prior art exists for acoustic ranging between phones (the
"BeepBeep" method and its successors), so any claim would need to rest on the
combination with court-geometry calibration and event gating.

### F6. Audio-anchored ballistic trajectory reconstruction

Each ball flight is modelled as a physics segment whose start and end times are
fixed by acoustic events, with sparse visual detections as observations. This
recovers contact height, net clearance and speed even when the ball is occluded
at contact or too small to detect in some frames. This is a concrete technical
method distinct from conventional frame-by-frame tracking.

### F7. Score-call speech recognition as outcome ground truth

Recognizing the announced score before each serve gives rally outcome, serving
team and server number, which validates or corrects the event-derived outcome
and enables automatic scoring without a scoreboard. Simple, specific, and likely
novel in this combination.

### F8. Multi-level ontology with re-derivation from stored events

The universal / professional / player / group ontology layers operate over an
event-sourced store so that classifications can be regenerated as ontologies
change. This may be better positioned as a dependent claim under F1 than as its
own family.

### F9. Learning measurement loop

Measuring the frequency and outcome of a targeted pattern before and after
instruction, attributed to a specific player and pattern. This may be a
dependent claim under F3 or a method claim of its own.

## 3. Prior art to review before filing

The following are known systems or publications in adjacent territory. The list
is from general knowledge and must be verified and expanded by counsel.

- Hawk-Eye and similar multi-camera ball tracking for officiating.
- PlaySight and other fixed multi-camera court systems with automatic clips.
- SwingVision, a single-phone tennis (and pickleball) tracking and statistics app.
- Zepp and Babolat sensor products that classify tennis strokes from a racket- or wrist-mounted inertial sensor.
- TrackNet and related academic work on small-ball detection in broadcast tennis and badminton video.
- Academic work on acoustic detection of ball impacts in tennis and table tennis.
- Academic work on stroke classification from smartwatch inertial data.
- The BeepBeep acoustic ranging method for commodity phones.
- Pickleball-specific video analytics products (verify current market entrants).

The distinguishing thread across F1–F3 is the chain from multimodal evidence to
a personalized, queryable representation with retrieval of the supporting
video, not any single sensing step.

## 4. Status against existing filings

A provisional application (v7) and a supplement (3) already exist in the
`sonicourt-app` project. F4 and F5 are covered there; F1–F3 and F6–F9 are
not. See document 06 §2.8 for the mapping.

## 5. Timing cautions

- Testing with students at a club, even informally, can constitute public use
  or disclosure. The United States offers a one-year grace period for the
  inventor's own disclosures; most other jurisdictions do not. File a
  provisional application before external testing, or run early tests only with
  participants under a confidentiality agreement.
- The engineering phases in `02-implementation-plan.md` produce measurable
  results (sync residuals, detection accuracy, matching accuracy). Those results
  make useful working examples for a specification and should be recorded with
  that in mind.
- Keep an invention log: dated notes of design decisions, especially F4–F7,
  which emerged from the engineering analysis rather than the original concept.
