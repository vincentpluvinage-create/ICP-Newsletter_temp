# 12 — Clip Coverage and Hit Spacing, MCC 11/16 Rally 5 and the Full Run

Computed 2026-11-19 from `TESTING/mcc-2026-11-16-b104.8-rally5/` in
`sonicourt-app` (strikes-171441-corrected.json, README, pad log). Bruno on
the TAPED half with the active watch (paired to phone P2); Ramiro on the
BLOCKS half, no watch. Hit times are the mean of the four arrivals on the
slot-1 master clock, not corrected for sound flight (≤ 25 ms).

## Current clip window

1.0 s before the hit, 2.0 s after: 3.0 s per clip, every shot. Compared
below with 1.0 s + 1.5 s.

## Rally 5

| Measure | Value |
| --- | --- |
| Hits | 27 (plus 31 landings filed as bounces) |
| First to last hit | 50.65 s |
| Median gap between hits | 1.58 s |
| Largest gap | 7.4 s (hits missing: soft dinks were filed as landings) |
| Sum of 27 clips at 3 s | 81 s, 1.6 × the rally |
| Union of the 1 + 2 s windows | 45.7 s, 90 % of the rally |
| Union of the 1 + 1.5 s windows | 43.7 s, 86 % |

## All eight rallies of run 3

| Rally | Hits | First to last, s | Median gap, s | Max gap, s | Union 1+2, s | Union 1+1.5, s |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | 10 | 15.5 | 1.41 | 2.9 | 18.5 | 17.4 |
| 2 | 12 | 18.1 | 1.47 | 3.5 | 20.6 | 19.6 |
| 3 | 5 | 5.3 | 1.43 | 1.6 | 8.3 | 7.8 |
| 4 | 2 | 0.4 | 0.36 | 0.4 | 3.4 | 2.9 |
| 5 | 27 | 50.6 | 1.58 | 7.4 | 45.7 | 43.7 |
| 6 | 12 | 17.5 | 1.46 | 2.9 | 20.5 | 19.6 |
| 7 | 15 | 42.6 | 2.53 | 5.9 | 39.4 | 36.3 |
| 8 | 1 | 0.0 | — | — | 3.0 | 2.5 |
| Total | 84 | 150.0 | | | 159.4 | 149.8 |

Gaps between consecutive hits inside a rally (n = 76): 10th percentile
1.13 s, median 1.57 s, 75th 2.38 s, 90th 3.04 s. 74 % are under 2 s and
89 % under 3 s, so with the 1 + 2 s window consecutive clips overlap in
89 % of cases and the union is simply the rally time plus three seconds.

## Ratios

| Denominator | Seconds | Union 1+2 | Union 1+1.5 | Sum of 3 s clips |
| --- | --- | --- | --- | --- |
| Rally time (first to last hit, all rallies) | 150 | 1.06 | 1.00 | 1.68 |
| Play period (first hit of rally 1 to last of rally 8) | 287 | 0.56 | 0.52 | 0.88 |
| PLAY step (17:18:08 to FINISH, about 7 min) | ≈ 420 | ≈ 0.38 | ≈ 0.36 | ≈ 0.60 |
| Whole run (17:14:41 to FINISH, about 10.5 min) | ≈ 620 | ≈ 0.26 | ≈ 0.24 | ≈ 0.41 |

## Two findings beyond the question

- **Missing hits.** 84 hits against 109 landings, and gaps of 5.9 and 7.4 s
  inside rallies, confirm the Mac note: soft dinks at the kitchen were
  filed as landings by the loudness rule. Any clip count per rally is a
  lower bound until that rule is fixed.
- **Wrist attribution.** With Bruno's watch on P2, 68 hits carry a wrist
  spike but only 21 are on Bruno's half; 47 landed on Ramiro's hits. The
  matcher takes the nearest spike within 1.5 s, and hits alternate every
  1.5 s, so Bruno's swing is handed to Ramiro's hit about half the time.
  The matcher needs exclusive assignment (one spike to one hit) and a
  side consistency check. This is a Phase 5 item for document 08.
