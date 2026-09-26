# 04 — Data Model and Shot Ontology

The unified structure that Applications A, B and C share. Six layers, each
derived from the one below and each carrying the version of the code that
produced it, so any layer can be regenerated from raw observations.

```
Observation  (raw media, sensor streams, sync map)         immutable
   ↓
Event        (impact, bounce, net contact, position, time)  derived, versioned
   ↓
Shot         (player, base type, attributes, measures)      derived, versioned
   ↓
Rally        (ordered shots, outcome, score)                derived, versioned
   ↓
Pattern      (sequence, support, outcome association)        derived, versioned
   ↓
Instruction  (reference links, comparisons, targets)         authored
```

## 1. Conventions

- Court frame: the prototype's `CourtSiteGeometry` frame. Origin at the net
  line × centreline; X along the net (positive toward a site-declared post);
  Y perpendicular to the net, positive into the half being described, with a
  `half` field naming it; Z up. Inches internally, feet for display, matching
  the tape-measured constants in the app. The corner-origin metric frame in
  `03-test-protocols.md` §0 is withdrawn (see document 06 §2.1).
- Master time is seconds since session start on the audio master timeline.
- Every derived record has `pipeline_version` and `source_ids`.
- Identifiers are ULIDs so records sort by creation time.

## 2. Observation layer

Session manifest (`session.json`):

```json
{
  "session_id": "01J...",
  "venue": "Club X court 3",
  "started_at": "2026-10-04T16:02:11Z",
  "court": {"length_m": 13.41, "width_m": 6.10, "nvz_m": 2.13,
            "net_center_m": 0.864, "net_post_m": 0.914},
  "devices": [
    {"device_id": "P1", "kind": "phone", "model": "iPhone …",
     "position_label": "baseline_A", "surveyed_xyz": [3.05, -3.0, 2.7],
     "video": {"w": 1920, "h": 1080, "fps": 60, "codec": "hevc"},
     "audio": {"rate_hz": 48000, "channels": 1}},
    {"device_id": "W1", "kind": "watch", "wearer": "player_A",
     "accel_hz": 100, "gyro_hz": 100}
  ],
  "players": [{"player_id": "player_A", "name": "…", "hand": "R", "watch": "W1"}],
  "consent": {"recorded_by": "…", "participants_consented": true}
}
```

Sync map (`sync.json`): for each device, a piecewise-linear map from device
clock to master time, plus the refined device positions from self-ranging and
the calibration record for each camera (intrinsics, extrinsics, homography,
reprojection error, valid time ranges).

Media and streams are stored as files under the session folder and never
modified.

## 3. Event layer

```json
{
  "event_id": "01J…",
  "session_id": "01J…",
  "t": 812.4173,
  "t_sigma": 0.0006,
  "type": "impact",
  "type_confidence": 0.98,
  "xyz": [1.2, 5.9, 0.78],
  "xyz_sigma": [0.08, 0.10, 0.06],
  "xyz_source": "triangulation+fit",
  "acoustic_xyz": [1.4, 5.7, 0.0],
  "acoustic_sigma_m": 0.35,
  "player_id": "player_A",
  "player_confidence": 0.99,
  "player_source": "wearable_match",
  "side": "forehand",
  "side_confidence": 0.93,
  "player_xy": [1.0, 5.6],
  "pipeline_version": "events-0.3.1",
  "source_ids": ["P1:aud", "P3:aud", "W1:acc"]
}
```

Event types: `impact`, `bounce`, `net`, `serve_call` (score announcement,
carries the recognised text and parsed score), `other`.

Flight segments link two events:

```json
{
  "flight_id": "01J…",
  "from_event": "01J…", "to_event": "01J…",
  "launch_xyz": [1.2, 5.9, 0.78], "launch_v": [1.1, 4.8, 2.3],
  "speed_mps": 5.4, "apex_z": 1.05,
  "net_clearance_m": 0.18, "crosses_net": true,
  "land_xy": [4.3, 7.9], "in_court": true, "in_margin_m": 0.31,
  "fit_rms_m": 0.04, "n_observations": 17,
  "pipeline_version": "traj-0.2.0"
}
```

## 4. Shot layer and ontology

### 4.1 Base types (universal ontology)

| Base type | Defining rule (v1, all measured) |
| --- | --- |
| serve | First impact of a rally, hitter behind baseline, ball bounced before? no |
| return | Second impact of a rally |
| drive | Ground stroke (ball bounced before contact), speed ≥ 12 m/s |
| drop | Ground stroke, lands in opponent NVZ, apex above net, speed < 10 m/s, hitter behind the NVZ line |
| dink | Ball lands in opponent NVZ, hitter within 1 m of own NVZ line, speed < 8 m/s |
| volley | Contact before bounce, hitter not at NVZ line, speed ≥ 8 m/s |
| roll volley | Volley with low contact (< 0.6 m) and net clearance < 0.3 m landing in NVZ |
| reset | Incoming speed ≥ 10 m/s, outgoing lands in NVZ with speed < 7 m/s |
| speed-up | Preceded by a soft exchange (≥ 2 shots < 8 m/s), outgoing speed ≥ 12 m/s |
| lob | Apex > 3 m, lands beyond opponent NVZ |
| overhead | Contact height > 1.9 m, downward launch angle |
| put-away | Volley or overhead ending the rally with speed ≥ 12 m/s |

Thresholds are starting values to be tuned on the golden set with the pro.
Rules are stored as data (`ontology/universal-v1.json`), not code, so the pro
can inspect them.

### 4.2 Attributes (apply to every shot)

| Attribute | Values | Source |
| --- | --- | --- |
| side | forehand, backhand | Event |
| direction | crosscourt, straight, inside-out | Launch and land x relative to hitter |
| spin | topspin, slice, neutral, unknown | Placeholder until measurable |
| intent | offensive, defensive, neutral | Speed, bounce depth, incoming speed |
| bounce_zone | nvz_short, nvz_deep, transition, deep, out | Land y |
| contact_zone | at_nvz, transition, baseline | Hitter y |
| contact_height_m | number | Event z |
| speed_mps, net_clearance_m, land_xy, time_to_bounce_s | numbers | Flight |

### 4.3 Context labels (derived from rally state)

| Label | Rule |
| --- | --- |
| third_shot_drop / third_shot_drive | Shot index 3 and base type drop / drive |
| dink_to_speedup | Speed-up whose two preceding shots are dinks |
| successful_reset | Reset whose next opponent shot is not a speed-up or put-away |
| counter | Shot following an opponent speed-up with speed ≥ 10 m/s |
| put_away | As base type, plus rally ends within one more shot |
| transition_reset | Reset with contact_zone transition |

### 4.4 Shot record

```json
{
  "shot_id": "01J…",
  "rally_id": "01J…",
  "index_in_rally": 3,
  "impact_event": "01J…", "flight": "01J…",
  "player_id": "player_A", "team": "AB",
  "base_type": "drop", "base_confidence": 0.91,
  "attributes": {"side": "backhand", "direction": "crosscourt",
                 "intent": "neutral", "bounce_zone": "nvz_deep",
                 "contact_zone": "baseline", "contact_height_m": 0.62,
                 "speed_mps": 7.1, "net_clearance_m": 0.33},
  "context_labels": ["third_shot_drop"],
  "outcome_local": "in_play",
  "ontology_version": "universal-v1",
  "pro_label": {"by": "pro_1", "base_type": "drop", "note": "good height"},
  "pipeline_version": "shots-0.4.0"
}
```

### 4.5 Ontology levels

| Level | Stored as | Example |
| --- | --- | --- |
| Universal | Rules and thresholds (4.1–4.3) | dink definition |
| Professional | Reference templates per class, chosen measures, success criteria | pro_1 forehand crosscourt dink: contact 0.79 m, clearance 0.18 m, bounce 0.56 m into NVZ, spread per measure |
| Player | Per-player distributions of measures per class, error rates | player_A backhand dink error 4% |
| Group | Pattern library and baselines for a set of players | ABCD third-shot patterns |

All four operate over the same shot records, so changing a universal
threshold or a professional criterion is a re-derivation, not a re-recording.

## 5. Rally, game, outcome

```json
{
  "rally_id": "01J…", "game_id": "01J…",
  "t_start": 810.9, "t_end": 819.3,
  "serving_team": "AB", "server": "player_A", "server_number": 1,
  "score_before": {"AB": 4, "CD": 2}, "score_source": "speech+events",
  "shots": ["01J…", "01J…"],
  "winner": "CD",
  "ending": {"type": "unforced_error", "error": "net", "by": "player_B",
             "shot_id": "01J…"},
  "reconciled": true,
  "pipeline_version": "rally-0.2.0"
}
```

Ending types: `winner` (untouched ball in), `forced_error`, `unforced_error`,
`fault`. Error kinds: `net`, `out`, `double_bounce`, `whiff`, `nvz_fault`.

## 6. Pattern layer

Tokens are generated at three abstraction levels for every shot:

```
L0  A:drop:BH:xc:3rd          player, type, side, direction, context
L1  team:drop:BH:3rd          team instead of player
L2  drop:3rd                  type and context only
```

State tokens are interleaved when relevant: `AB@transition`, `AB@nvz`.

```json
{
  "pattern_id": "01J…",
  "level": "L0",
  "sequence": ["A:drive:FH:3rd", "CD:volley", "AB@transition", "CD:speedup"],
  "support": 41,
  "wins": 12, "losses": 29,
  "win_rate": 0.29, "ci95": [0.17, 0.45],
  "baseline_win_rate": 0.51, "shrunk_win_rate": 0.33,
  "q_value": 0.03,
  "rally_ids": ["01J…"],
  "text": "When A drives the third shot and AB are still in transition when CD speed up, AB win 29% of rallies (baseline 51%).",
  "pipeline_version": "patterns-0.1.0"
}
```

Patterns with support below a configurable minimum are stored but flagged
`insufficient`, never shown as findings.

## 7. Instruction layer

Authored records that link the other layers:

- `reference`: professional template for a class (see 4.5).
- `comparison`: student shot, chosen exemplar, pro reference, chosen measures,
  rendered clip paths.
- `target`: a pattern or class a player is working on, with an instruction date
  for the before/after report.

## 8. Storage layout

```
sessions/<session_id>/
  session.json
  sync.json
  media/P1.mov P2.mov P3.mov P4.mov
  streams/W1.parquet W2.parquet
  derived/<pipeline_version>/
    events.parquet flights.parquet shots.parquet rallies.parquet
library/
  ontology/universal-v1.json
  references/<pro_id>/<class>.json
  patterns/<group_id>/<version>.parquet
```

The analytics store (DuckDB or PostgreSQL) is rebuilt from `derived/` and is
disposable.

## 9. Example queries

Each of the instructor requests in the concept write-up maps to a filter over
the shot and rally tables plus a media lookup.

| Request | Query shape |
| --- | --- |
| Every rally where Vincent attempted a backhand speed-up from the left kitchen line | shots where player = Vincent, base_type = speed-up, side = backhand, contact_zone = at_nvz, player_x < 3.05 → rally_ids → clips |
| Rallies where the serving team reached the kitchen after a third-shot drop | rallies where shot 3 has third_shot_drop and the serving team's position state reaches `@nvz` before the rally ends |
| Compare successful and unsuccessful transition-zone resets | shots where base_type = reset, contact_zone = transition, split by outcome of the next two shots; return measure distributions and clips |
| Five most common rally sequences preceding AB's losses | patterns at L1 filtered to team AB losses, ordered by support |

Clips are cut from the original media using event times mapped back through
the sync map, with a configurable lead and trail.
