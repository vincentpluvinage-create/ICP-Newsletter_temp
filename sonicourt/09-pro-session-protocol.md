# 09 — Protocol for the Sessions with Pickleball Professionals

Purpose: run a small number of sessions on regulation painted courts with
teaching professionals that (a) validate the four-phone system where it has
never been tested, (b) generate the evidence listed in document 08 §4 for
the comprehensive provisional, and (c) record the first professional
reference shots for the teaching application. Each block names the
inventory items it evidences.

## 0. Before the first session

**Legal and consent.** File the new provisional first, or have each
professional and participant sign a confidentiality and recording consent
before arriving. Record the signed date in the invention log. Consent
covers video, audio, wrist motion, and the use of recordings as patent
evidence and as teaching references.

**Hardware.** KIT iPad on a tripod at a post, four kit iPhones in four
fixtures, four watches (one per player, paired and launched from the
phones), the monitor if the court has power, two brass clickers, a tape
measure, a laser distance meter, a string and two stands for a net-clearance
gauge, a radar gun if one can be borrowed, the marker kit (bands in four
colours, two-tone edge rings in fluorescent vinyl with a retroreflective
stripe, plain tape as control), battery packs, and a USB-C cable for the
pull.

**Software.** Build 104.10 or later with: the serve photo, clicker
calibration, hands-free serving, and the paint-line court fit (build 70)
re-enabled beside the pink-line fit, since the court is painted. Confirm
before the session that the painted-line fit returns green consistency on
a photo of the target court. Enrol each player's three "serving" voice
takes at the court, not at home.

**Court record.** Measure and record: post inner-face spacing, mic-to-mic
after seating, kitchen line and baseline distances, surface colour, line
colour and width, net height at centre and posts, air temperature, sun
direction. Photograph each fixture seated with the serial visible.

**Operational checks.** iPad off Wi-Fi with hotspot on; Wi-Fi Aware pairing
confirmed on all four phones; a 60 s dummy session with FINISH and collect to
confirm the day folder forms; record collect time.

## 1. Session plan

Two sessions of about two and a half hours each are enough for the evidence.
A third session is for the teaching application if the professionals are
willing. Blocks are ordered so the early ones protect the later ones' data.

### B0. Setup, calibration and drift (25 min)

1. Seat fixtures, read tags, PLACE each phone (level under 3°).
2. CALIBRATE: 16 rounds of the four-phone chirp schedule. Record every pair's
   offset, distance and drift, the loop closures, and the same-post
   separations against the tape.
3. Clicker calibration: three clicks at the T and at both kitchen-line ends,
   any order; then nine more clicks at surveyed points along the baseline
   and sidelines as a check set not used by the fit.
4. T bounces: five bounces on the T; record the side reference per pair.
5. Leave the ping loop running for the whole session; at the end compare
   the first and last offsets per pair against the fitted drift line.

Evidence: S5, S8, S9, S12, S13, L4. Pass: same-post separations within
1 in of tape, across-post distances within 2 in, check-set clicks solved
within 6 in, drift residual under 0.5 ms over the session.

### B1. Known-position hits on a painted court (20 min)

One professional hits balls from marked spots: three per spot at the
kitchen-line ends, the T, the baseline corners, the baseline centre, and
mid-court on both sides; five hits per spot. Ground truth is the marked
spot plus the ball detector's bearing from the facing cameras. Then **swap
the two phones of one post** and repeat the corner spots only.

Evidence: L5, L6, L8, L9, V11, S11. Pass: mid-court rms under 6 in, corner
bias reported per phone before and after the swap, hit-versus-landing rule
correct on every landing. Optional: a fifth phone on a tripod behind one
baseline, recording audio only, to test the off-net microphone for corner
geometry (document 08 §4).

### B2. Painted-line court fit with four cameras (15 min)

With no one on court, let each phone accumulate the fit for three minutes.
Record consistency in pixels for each camera. Then one person walks the
kitchen line, the centre line and both sidelines on each half. Compare feet
positions between the two cameras facing each half and against the line.

Evidence: V3, V4, V5, V6, V9, V12. Pass: consistency green on all four
cameras; two-camera feet agreement under 9 in; walked-line error under
6 in at the kitchen line and under 12 in at the baseline.

### B3. Rule calls and server identification (15 min)

A professional serves twenty times from legal positions on each half, then
ten deliberate foot faults (baseline, centre-line extension, sideline). A
second person stands as a doubles partner for half the serves. Ground
truth is a referee at the baseline plus the strike bursts.

Evidence: V7, V8, R4, L4. Pass: side correct on every legal serve; no fault
called on a legal serve; faults detected on at least 8 of 10 with the
across-court camera green.

### B4. Markers (25 min)

For each marker type (plain band, two-tone fluorescent ring with
retroreflective stripe, plain tape control): serve stills at both serving
spots on both halves, once in sun and once in shade if the court offers
both, with and without the torch. Then a two-minute rally with each marker
while the strike bursts record.

Evidence: M1–M4, V14. Measure: marker size in pixels and colour separation
in the stills; fraction of strike bursts where the marker is identifiable
in the frame 100 ms before contact; face identification (A or B) against
the referee's note of forehand or backhand; the ring's projected aspect
ratio against a protractor reading of the paddle angle on ten held poses.

### B5. Serve ritual and word trigger in play (15 min)

Thirty serves alternating halves and servers, each preceded by the spoken
word, with normal conversation allowed between serves; then ten minutes of
court-side conversation with no serve. Record every burst that reached the
word gate.

Evidence: P2, P3, P4. Pass: at least 27 of 30 serves announced correctly
with the right name and side; zero announcements during the conversation
block; time from word to announcement under 3 s.

### B6. Doubles attribution with four watches (20 min)

A doubles game to 7 with all four players wearing watches and markers.
Referee notes the hitter for every shot on a card, with forehand or
backhand. After FINISH, score attribution from the watch match, from the
marker, and from their fusion, against the card; score forehand/backhand
from the gravity sign and from the ring face.

Evidence: W1–W4, M2, S16. Pass: attribution at least 95 % from the watches
alone; forehand/backhand at least 90 % from either cue; report the fusion
rate and the disagreement cases.

### B7. Professional reference shots (35 min)

The professional performs sets of twenty: forehand and backhand crosscourt
dinks, straight dinks, third-shot drops from the baseline, third-shot
drives, forehand and backhand volleys from the kitchen line, resets from
the transition zone, and serves. The professional says the shot name before
each set. A string gauge above the net at 6, 12 and 24 in gives net
clearance truth for dinks and drops; the radar gun, if present, gives speed
truth for drives and serves; chalk-dusted balls mark bounce spots for ten
dinks and ten drops.

Evidence: R7, R8, A7, V11, W4, P1. Deliverable: the first professional
reference library with measured contact position, launch direction, net
clearance, bounce location and the wrist window per shot; the dink and drop
sets are the input for the dink-drill vertical slice of Application A.

### B8. Games (remaining time, at least two games to 11)

Full games with the score called aloud before each serve. No referee taps;
a card records the winner of each rally and the error type. Rally
boundaries, side of net, hitter and outcome are scored afterwards against
the card. The recordings of the score calls are the dataset for P5.

Evidence: R1, R3, A7, L4, W3, P5 (data only). Pass: rally boundaries 98 %;
side of net 99 %; hitter 95 %; collect complete.

## 2. After each session

1. FINISH, wait for collect, then pull every phone by USB as well; verify
   file counts against the pad log.
2. Write the session report in the format of the 10/26, 10/28 and 11/07
   reports: headline numbers, per-block tables, open items. Commit it under
   `TESTING/<venue>-<date>/` with the pad log, impacts files, strikes file,
   quad clusters and figures, so the evidence lives in the repository and
   not only on the Mac.
3. Add dated entries to the invention log for anything conceived on court.
4. Send the professional their reference clips and the measured table for
   their own shots; ask which measurements they consider pedagogically
   relevant. That answer is the first content of the professional ontology
   (document 04 §4.5).

## 3. Minimal variant

If only one session is possible, run B0, B1 (without the fifth phone), B4,
B5 and B6, then one game. That covers families 1, 2, 5, 6 and 7 of document
08 §2 with field data and leaves the teaching library for a later date.
