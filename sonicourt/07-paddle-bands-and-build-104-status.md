# 07 — Paddle Bands and the State at Build 104.10

Written 2026-11-19 from `PADDLE-BANDS-MEMO.md` (2026-11-18) and the
`sonicourt-app` repository at build 104.10. Document 06 was written against
build 74 on 2026-09-26 and its "what exists" table is now out of date; section
2 below replaces it. Section 1 folds the paddle-band idea into the plan.

## 1. Coloured paddle bands

### 1.1 The idea as discussed on 11/17–11/18

Each player slips a coloured silicone grip band onto the paddle at the top of
the grip. To serve, the player stands behind the baseline, holds the paddle
vertical in front of the body and says "serving". The phones hear the word,
find a person with both feet behind a half-baseline holding a paddle up, and
read the band colour. That yields who is serving and from which court with no
tap, and lets the iPad speak "Bruno serving left, 2-1-1".

Status at 104.10: the serve photo and the hands-free word trigger are built;
colour recognition is not; nothing has been tested on court.

### 1.2 Where it sits in the plan

The band is a passive identity cue for the cameras. In the plan's terms it is
a third attribution source alongside the wrist spike (watch) and the acoustic
side call, and it is the only one that covers a player without a watch. It
belongs in Phase 5 (identity) and feeds Phases 7 and 8 (score state and the
teaching application), where "who hit it" has to be right before anything
downstream is credible.

What the memo gets right, and the plan adopts:

- **The pixel budget decides the marker, not the band.** At 1080p a band of
  1.3 × 0.5 in on a player 25 ft away is roughly 4 × 2 px, and chroma is
  stored at half resolution, so the band is one or two colour samples. The
  memo's answer is correct: a 12-megapixel still taken while video continues
  gives the resolution over the whole field without disturbing the line fit,
  the feet or the serve clip. Zoom does not, because it is centred and
  changes the calibration.
- **A larger marker for the cameras, the band for the players.** Coloured
  tape along the paddle edge or a sticker on both faces gives ten to fifty
  times the pixels. The band stays as the visible token and the enrolment
  colour.
- **Colour set that the court does not own.** Blue and green are the court,
  yellow-green is the ball, red and pink merge at this size. Candidates to
  confirm on real stills: red, orange, white, purple or magenta.
- **Enrol on court under the day's light.** Each player raises the paddle
  once at STARTING POSITIONS; the phones store that colour. This is the same
  principle as the ball detector's per-session colour gate (build 80) and
  should reuse that mechanism.
- **Three cues, not one.** Pose gives the court, colour gives identity, the
  score state confirms both.

### 1.3 What the plan adds

- **Serve identity is the easy case; rally identity is the hard one.** At the
  serve the player is still, facing a known direction, with the paddle raised
  on cue. During a rally the paddle moves at several metres per second and is
  seen edge-on half the time. The band and tape should be evaluated for the
  rally case from the strike bursts and clips already collected, not only
  from the serve still. If the marker is readable in the 100 ms before
  contact in a useful fraction of hits, it becomes a rally attribution cue as
  well; if not, it stays a serve cue and the watch carries the rally.
- **Doubles switch tracking.** The memo notes that colour matters after a
  switch. The plan's rally model should carry a "who is where" state updated
  by every attributed hit, so a missed read is bridged by the last known
  position rather than left undecided.
- **A colour read is a descriptive label.** Following the fault-rule
  precedent (destructive calls need green consistency), a colour read that
  contradicts the watch spike or the score state should be logged and
  withheld, not spoken.
- **Patent note.** A passive colour marker on sports equipment is likely old
  on its own. The combination that may be distinctive is the serve ritual:
  spoken word as the trigger, feet-behind-baseline gate, high-resolution
  still during continuous video, colour enrolled per session, fused with the
  wrist spike and the score state. Record it as a dependent concept under
  the attribution family in document 05.

### 1.4 Test plan addition (Phase 5)

The 104.10 driveway runbook already defines the first test: each band at
both serving spots, then edge tape, then the paddle face to a post, with the
band's pixel size and colour separation measured from the stills and scaled
to a 22 ft baseline. Add to it:

| Test | Procedure | Pass |
| --- | --- | --- |
| T5.6 Marker readability at the serve | Stills from both facing cameras, four colours, two spots, three lighting conditions (midday, late afternoon, shade) | Each colour separated from the other three and from the court, ball and skin in every still |
| T5.7 Marker readability in rallies | Strike bursts from a short rally with each marker; count hits where the marker is identifiable in the frame 100 ms before contact | Report the fraction per marker type; no pass threshold yet, this sets the design |
| T5.8 Word trigger false positives | Thirty minutes of court-side conversation with the phones listening and no serve | Zero spoken announcements; every burst that reached the word gate logged |
| T5.9 Still-capture side effects | Compare audio timing residuals and video ring gaps with and without the still | Residual change under 0.2 ms; ring gap under one frame |

## 2. State at build 104.10 (replaces document 06 §1)

Thirty builds landed between build 74 (2026-08-24) and build 104.10
(2026-11-18). The summary below is from the commit history, the module headers
and the session reports in the repository, not from a line-by-line review.

| Area | State at 104.10 | Plan phase |
| --- | --- | --- |
| Rig | Four iPhone 15 kit phones, two per post in fixtures, one iPad, a USB-C monitor at the net post as a big screen. The fixtures carry NFC tags that declare the post. | Phase 1 |
| Links | Wi-Fi Aware as the primary phone-to-iPad link (build 98, Apple TN3213), peer-to-peer connection in 0.3–1.6 s, Multipeer and Bluetooth as fallbacks; stall rules settled in 97.6. | Phase 1 |
| Timing | Ping loop every 10–30 s between phones replaces the iPad-on-T calibration as the product timing path; drift fitted per pair (−4 to −17 ppm measured across six pairs); hybrid first-wavefront cross-correlation re-times each pair (build 90); clicker calibration at the T and kitchen-line ends solves the pair latency offsets and the same-post bearing (104.7–104.10). | Phase 1 and 3 |
| Acoustic localization | Four-mic solver gives contact point across the court from the post pairs and bearing from the same-post pairs (104.7). Four consecutive four-phone sessions with every loud hit on the correct side; mid-court x within 1–6 in on the 10/28 smoke test; corners carry a one-sided bias of about 12 in traced to one phone's onset shape, with the phone swap as the decisive test. | Phase 3 |
| Vision | Pink-line fit for taped driveway courts (93b) with two cameras agreeing on feet to 9 in; ball detector on strike bursts with per-session colour gate (79–80), range from apparent diameter, bearing from column; camera fusion on 10/28 showed 4 in scatter in the hits' own placement; serve photo at full still resolution with the feet gate (104.9). | Phases 2, 4, 5 |
| Watch | Zero-tap launch from the phone, spikes streamed as sensed, self-healing workout, 300 ms accelerometer and gyro window per hit streamed to the phone as stroke material (93–95). | Phase 5 |
| Speech | Own "serving" detector: speech-band burst, MFCC and DTW against the player's three welcome takes, two phones within half a second (103.1). Serve now hands-free (104.10). | Phase 7 |
| Rally | Rally opens on the serve, closes 3 s after the last hit; clip per confirmed strike from the facing pair; REVIEW on the iPad and on the big screen with the court map and the watch reading (101–102). | Phase 7 and 8 |
| Backend | Idempotent upload of the iPad day folder to a Cloudflare Worker with R2 and D1 (81–82); player self-registration for SMS clip links (83). | Data model, storage |
| Collect | Works over the mesh; 78 min for 2,300 files on 11/07, so USB pull per phone is routine until a bulk channel exists. | Operations |
| Product direction | GAME mode and the RALLY COMPILATION (11/05): serve ritual, spoken announcement, hit-by-hit clips from the best camera with a growing court diagram, shared by SMS. | Application A seed |

### 2.1 What this changes in document 06

- **Calibration.** The ping loop and the clicker calibration supersede the
  "scheduled-window chirp listening" recommendation in 06 §2.2. The problem
  that recommendation addressed, drift over long sessions, is solved by the
  ping loop; the open question is now the per-phone onset bias at the
  corners, which the hybrid re-timing partly removes.
- **Video.** The JPEG ring remains the capture path. 06 §2.3's ask for a
  continuous hardware-encoded 1080p60 recording still stands and is now more
  pressing: the ball detector works on strike bursts only, and the rally
  compilation will want full clips at better than 30 fps. The serve still
  (104.9) is a second reason, since it already competes with the ring for
  the camera.
- **Acoustic localization.** 06 §2.4 said four phones on two posts localize
  only along the net. The same-post pairs at 8–9 in separation do give a
  bearing, and the clicker calibration makes it usable. Depth from sound is
  therefore coarse but real, and the plan's bounce localization can take it
  as a prior for the camera homography.
- **Wearable.** The W0 logger is now a streaming per-hit window source. The
  stroke classifier still needs labelled data; the scope review's advice to
  keep a spoken stroke label in PLAY is the right way to collect it and
  matches the plan's Phase 6 annotation approach.
- **Phase 7.** The serve ritual, the word trigger and the rally open/close
  rules are the first pieces of the plan's rally segmentation. Score-call
  speech recognition (plan F7) now has a home: the same word detector,
  extended from "serving" to the score digits.
- **Patents.** The word-triggered serve ritual with the feet gate and the
  high-resolution still, the clicker calibration of pair latency and
  same-post bearing, and the hybrid first-wavefront re-timing are three more
  candidate concepts not listed in document 05.

### 2.2 Revised phase status

| Phase | Status at 104.10 |
| --- | --- |
| 0 Feasibility | Done |
| 1 Capture and sync | Done for four phones on a taped court; continuous 1080p60 recording still open |
| 2 Calibration | Pink-line fit done for the driveway; painted-court fit from build 70 needs re-validation with four phones on a real court |
| 3 Acoustic events | Localization in two dimensions done; event classes beyond the paddle transient still open; soft events (ball landings) are filtered offline only |
| 4 Ball trajectory | Detector and single-frame range and bearing done; no trajectory fit yet; needs the full-rate recording |
| 5 Identity | Watch streaming done; band capture built, recognition not started; forehand/backhand material being collected |
| 6 Shots and ontology | Not started; labelled stroke windows are the first dataset |
| 7 Rallies and outcomes | Serve ritual, word trigger and rally boundaries done; score state machine and outcome rules not started |
| 8 App A | REVIEW and big-screen playback done; rally compilation specified; reference and comparison features not started |
| 9 App B, 10 App C | Not started |

### 2.3 Next steps, in the order the repository suggests

1. Run the 104.10 driveway test and settle the marker and colour set from
   the stills (memo §Next 1–2; tests T5.6 and T5.7 above).
2. Build colour recognition and the score state machine together, as the
   memo says, so each checks the other.
3. Add the continuous 1080p60 recording before the rally compilation, so the
   compilation and the ball trajectory share one source.
4. Start the labelled stroke dataset in PLAY; it costs nothing per session
   and gates Phase 6.
