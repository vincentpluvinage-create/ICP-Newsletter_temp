# 06 — Reconciliation with the Existing `sonicourt-app` Prototype

Documents 01–05 were written from the concept write-up alone. This document
reconciles them with the `vincentpluvinage-create/sonicourt-app` repository
(build 74, last pushed 2026-08-24), which contains a working two-phone serve
localization prototype, a Watch wrist logger, offline analysis tools, and
field data from roughly ten club and driveway sessions between 2026-08-02 and
2026-08-24. Where this document and documents 01–05 disagree, this document
wins.

## 1. What already exists

| Area | State in `sonicourt-app` | Plan phase it covers |
| --- | --- | --- |
| Capture rig | Two iPhones in Design B Rev 9 aluminium holders on the net posts (lens 32 in high, 27° from net-perpendicular), one iPad controller. Four holder slots exist in the UI (two per post) for the doubles build. | Phase 1, two-phone form |
| Audio | 48 kHz sample-indexed capture, crest-factor transient detector tuned on clap and paddle sessions, full-session `.caf`, `impacts.jsonl` with sample, uptime and wall stamps, `blocks.csv` per 100 ms. Built-in mic pinned; interruption, route-change and media-reset recovery. | Phase 3 detection, single class |
| Clock sync | iPad placed on the kitchen T (equidistant from both post mics) chirps eight times; arrival difference is the offset θ directly. Two-way phone exchange solve and affine drift model exist. Round-robin ranging gives three two-way distances with triangle closure. Measured drift −7.84 ppm; spread typically 0.35–1 ms; quality gate and drift-epoch rejection after engine restarts. | Phase 1 sync |
| TDOA | Serve side from the sign of Δt across the 22 ft post baseline, off-court gate at 0.45 τ, corner acceptance with vision confirmation, intensity tiebreaker. 46/46 on the 8/10 announced set. | Phase 3 localization, one axis |
| Camera | 1080p ~30 fps JPEG ring (4.5 s), retroactive strike bursts, pre-roll clips −1 s/+2 s encoded from the ring, survey mode, iPad clip gallery, continuous gravity rotation, jolt watch. | Phase 1 capture, partially |
| Court calibration | Automatic painted-line detection (court-hue hull, top-hat paint validation, centerline RANSAC), then a pose-constrained 3-DOF fit with camera position fixed by bracket geometry and focal 1300 px. Dense paint-offset consistency signal (green ≤5 px, amber ≤12 px). Both post sides and both lens heights tried automatically. Offline refinement reached 1.2–1.4 px RMS. | Phase 2, served half only |
| Vision | Ankle midpoints → court feet through the homography; L/R side vote weighted by distance from centreline and person size; fault flags (baseline, centreline, sideline) accepted only from the across-court camera with green consistency. Ball-near-wrist server identification validated offline (median 23 px). | Phase 5, serve only |
| Wearable | Watch app: workout session, 800 Hz batched accelerometer where supported else 100 Hz, 3.5 g spike detector with 150 ms refractory, `wrist.jsonl` shipped through the phone. Offline pattern-correlation clock fit planned (±100 ms tolerance). Target disabled in builds 73–74 pending HealthKit provisioning. | Phase 5 wearable, the W0 step |
| Rally mode | Hits within 4.5 s belong to one rally; rallies of ≥4 hits keep the last three pre-roll clips; iPad cross-pairs phone detections through the TDOA window to reject echoes (log-only). | Phase 7, seed |
| Networking and ops | QR-rendezvous direct TCP socket over the iPad hotspot (pairing ~1–2 s), Multipeer fallback, heartbeats with capture liveness, thermal state and battery, health chips, watchdogs, one-folder-per-day collection on FINISH. | Not in the plan; needed by every phase |
| Test practice | Printed serve cards, blind blocks, photo-verified feet truth, BLOCK markers in the pad log, three-way cross-check (card, referee taps, log), per-session reports. | `03-test-protocols.md` conventions |
| Product signal | 2026-08-07: players value ~3 s clips of each hit more than automatic scoring. Clips became the headline feature. | Shapes Application A |
| Patents | A provisional (v7) with notes on dual-solve calibration, range check, clip ring, rally grammar and net-cord signature; supplement 3 covers the wrist logger. | `05-invention-concepts.md` |

## 2. What this changes in documents 01–05

### 2.1 Physical layout (supersedes 01 §4)

The plan proposed two elevated baseline cameras plus two net-side cameras.
The prototype's net-post design is better on the axis that matters most and
should stay the anchor:

- From a post camera at 32 in with a 1300 px focal, the ball at the far
  baseline of its half (~25 ft away) is about 13 px across at 1080p and about
  24 px at the kitchen line. The plan's baseline camera saw 6 px at the far
  end. The post cameras also see the net tape edge-on, which is what net
  clearance needs.
- The natural four-phone configuration is therefore two phones per post, one
  facing each half, which is exactly the four holder slots already in the
  pairing screen. Each half is then seen by two cameras with a 22 ft stereo
  baseline, which is enough for triangulating contact height and net clearance.
- The weakness of post cameras is depth resolution along the court at low
  height: a bounce 20 ft away moves few pixels per foot of depth. The
  audio-anchored physics fit (plan D6) and the second camera at the other post
  compensate. Elevated baseline cameras remain an option if bounce depth
  accuracy for dinks fails its gate, not a default.

Coordinate frame: adopt the prototype's `CourtSiteGeometry` frame (origin at
net line × centreline, X along the net, Y perpendicular into the half in
question, Z up, inches internally, feet for display). Document 04 §1 is
amended below. The plan's corner-origin metric frame is withdrawn.

### 2.2 Synchronization (amends 01 R1 and 02 Phase 1)

The prototype solved θ for two phones with the iPad-on-T method and learns
drift from two runs. Three gaps remain for the full system:

1. **Long sessions.** At −7.84 ppm, drift is about 0.5 ms per minute and 42 ms
   over 90 minutes. Two calibration runs at the start extrapolate the drift
   line, but engine restarts re-anchor the sample clock (documented in the
   build-38 findings). The plan's continuous chirps are still needed, but not
   as originally described: build 74 turned passive chirp listening off because
   the matched filter on the tap thread starved the pipeline. The fix is
   scheduled listening: the pad announces the chirp time over the socket, and
   each phone runs the matched filter only in a ±200 ms window around it. This
   keeps the sync cost at a few milliseconds of CPU every ten seconds.
2. **Four phones.** The backlog already names the path: the iPad on either
   kitchen T is equidistant from both posts, so both halves calibrate the same
   way, and the two-per-post phones share a post and can be cross-checked by
   the phone-to-phone exchange at zero distance.
3. **Watch clock.** Supplement 3's pattern-correlation fit of wrist spikes
   against acoustic impacts is the plan's F4 mechanism. It should run offline
   first, exactly as the Watch memo intends.

Phase 1's gate stands (residual < 0.5 ms across a session) and is now a
regression test on existing infrastructure rather than new work.

### 2.3 Video capture (amends 02 Phases 1 and 4)

The JPEG ring at 30 fps was designed for strike bursts and 3 s clips, and it
is a documented thermal load. Ball tracking needs two things it cannot give:
60 fps or better, and every frame of the session. Recommendation:

- Add a continuous hardware-encoded recording (HEVC, 1080p60) written with
  `AVAssetWriter` in parallel with the existing pipeline. It costs little CPU
  because the encoder is hardware, and the frames carry the same host
  timestamps the ring already uses.
- Shrink the live ring to a downsampled stream (e.g. 640 × 360) used only for
  framing, court calibration and the live person vote. Cut clips after the
  fact from the full recording by timestamp instead of re-encoding JPEGs.
- Keep the strike-burst JPEGs, since the offline tools and the pad Review
  screen depend on them.

This is the single largest change the plan asks of the phone app and it is
the prerequisite for Phase 4.

### 2.4 Acoustic events (amends 02 Phase 3)

The detector is one-class (paddle transient). The plan's four-class detector
(impact, bounce, net, other) is new work, but the data to build it already
exists: full-session `.caf` files from every session, with bounces measured
at about −30 dB and 0.8 s after each serve, and drop-serve blocks recorded
specifically for bounce-versus-strike discrimination. The provisional's
4–12 kHz brightness discriminator is the starting feature. Phase 3 becomes an
offline classifier trained on the archive first, then ported.

Two-dimensional localization needs at least three non-collinear microphones.
Two phones per post are nearly collinear with the other post, so the four-phone
array still localizes only along the net axis well. For the court gating in
plan R3 this is enough (adjacent courts sit off that axis); for bounce
localization the camera homography remains primary, as the plan says.

### 2.5 Player identity and shots (amends 02 Phases 5 and 6)

The serve-only fusion (L/R/FAULT, across-court fault judge, consistency
gating) generalizes to rally shots without change of principle: the impact
localizes to a side by TDOA sign, the across-court camera judges feet, the
near camera confirms. What is new is attribution among four players, which
the wrist logger addresses, and forehand/backhand, which is not started.

The "L/R has priority, fault only when green" rule is a good template for the
plan's shot classifier: destructive labels (faults, errors) require higher
evidence than descriptive ones (shot type, side).

### 2.6 Rally segmentation (amends 02 Phase 7)

Rally mode already implements the silence-gap rule (4.5 s) and the echo
cross-pairing. The runbook's capability notes specify the rest of rally
grammar v0: net-cord signature (loud and near-simultaneous at both posts),
last-bounce and last-hit tagging, and the last-two-clips rule for the winning
shot. The plan's score-call speech recognition is not in the prototype and
remains the cheapest route to outcome ground truth.

### 2.7 Data model (amends 04)

The day folder is the observation layer. The plan's `session.json` and
`sync.json` should be produced by an importer over the existing files, not
by changing what the phones write:

| Existing file | Plan layer |
| --- | --- |
| `sess-<stamp>[-pN].caf`, `-blocks.csv`, `-impacts.jsonl` | Observation, audio |
| `-impN-k-t<hostMs>.jpg`, `-survey…`, `-rally…-clip.mov`, `-calibpos-…jpg` | Observation, video |
| `sess-<stamp>-wrist.jsonl` | Observation, wearable |
| Pad log lines SESSION, SIDES, CALIB, CALIB-COMPARE, RANGE, ROBIN, GUESS, TRUTH, REF, BLOCK, BATT, HEALTH, PAIRDIAG, FAULT-WITHHELD | Session manifest, sync map, truth labels |
| `ServeRecords` | Shot layer, serve subset |

Known hazards to inherit: session-stamp collisions when two phones start in
the same second (fix queued: append the post id), sample-clock re-anchoring on
engine restart (handled by uptime and wall stamps), and per-day rather than
per-session folders.

### 2.8 Invention concepts (amends 05)

| Plan family | Status against the prototype's filings |
| --- | --- |
| F1 pro reference ontology | New |
| F2 student matching and synchronized retrieval | New |
| F3 outcome-associated sequences with retrieval | New; rally grammar v0 in the provisional is a precursor |
| F4 wrist-to-acoustic impact matching | Already the subject of supplement 3 |
| F5 self-synchronizing acoustic array bound to court geometry | Already in the provisional (dual-solve calibration, range check, round-robin) |
| F6 audio-anchored ballistic trajectory | New |
| F7 score-call speech recognition | New |
| F8 multi-level ontology with re-derivation | New, likely dependent on F1 |
| F9 learning measurement loop | New, likely dependent on F3 |

The plan's public-use caution is moot for what the provisional already
covers. F1–F3 and F6–F7 are not yet in any filing and are the ones to
protect before they are demonstrated to students or players.

## 3. Revised phase status and order

| Phase | Status | What remains |
| --- | --- | --- |
| 0 Feasibility | Done, exceeded | Archive answers the questions; write the findings memo from existing session reports |
| 1 Capture and sync | Mostly done for two phones | Scheduled chirp listening for drift; four-phone calibration on both Ts; continuous 1080p60 recording; re-enable the Watch target |
| 2 Calibration | Done for the served half from a post camera | Extend anchors to the full court and the net tape for off-plane triangulation; verify with the second camera per half |
| 3 Acoustic events | Detector for paddle transients done | Bounce and net classes; scheduled-window architecture; four-track association |
| 4 Ball trajectory | Not started | As planned, after 2.3 |
| 5 Identity | Serve-only vision done; Watch W0 built but disabled | Offline wrist-acoustic matching on the next session; forehand/backhand; multi-player attribution |
| 6 Shots and ontology | Not started | As planned; start with dinks and drops from post cameras |
| 7 Rallies and outcomes | Rally mode and echo pairing done | Net-cord signature, last-hit tagging, outcome rules, score-call recognition |
| 8 App A | Clip gallery and review screen are the seed | As planned; the clip-first product signal supports leading with A |
| 9 App B | Not started | As planned |
| 10 App C | Not started | As planned |

### Recommended next three builds

1. **Build 75: recording and sync groundwork.** Continuous 1080p60 HEVC
   recording alongside the ring; scheduled-window chirp listening; Watch target
   re-enabled; post id appended to session stamps.
2. **Build 76: four-phone session.** Two phones per post, calibration on
   both kitchen Ts, per-half TDOA and court fits; one club session with all
   four players wearing watches; wrist-acoustic matching run offline that
   evening.
3. **Offline, in parallel:** bounce/net classifier on the archive; first ball
   detector fine-tuned on strike bursts and clips; dink-drill trajectory fit
   against a string gauge at the net.

The dink-drill vertical slice of Application A remains the first product
milestone, now reachable sooner because Phases 0–2 are largely behind you.
