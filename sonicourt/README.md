# Sonicourt — Planning Package

Multimodal pickleball shot intelligence, teaching and strategy system.

This folder turns the Sonicourt concept write-up into an engineering plan: an
analysis of the architecture, a phased build order with test gates, concrete
test protocols, a data model, and notes separating the invention concepts.

| File | What it contains |
| --- | --- |
| `01-architecture-analysis.md` | What the concept gets right, the hard problems ranked by risk, the key design decisions, the recommended physical layout and sensor budget. |
| `02-implementation-plan.md` | Eleven phases from a no-code feasibility week through Applications A, B and C, each with deliverables, tests and a go/no-go gate. |
| `03-test-protocols.md` | Step-by-step test procedures, ground-truth methods, datasets to collect, metrics and pass criteria. |
| `04-data-model.md` | The unified event → shot → rally → outcome → pattern → instruction structure, JSON schemas, the shot ontology as a spec, versioning rules and example queries. |
| `05-invention-concepts.md` | The three claim families identified in the write-up plus additional candidates exposed by the engineering plan, prior-art awareness and timing cautions. |

## One-paragraph verdict

The concept is sound and the hierarchy (sensor evidence → event → shot → rally →
outcome → pattern → instruction) is the right spine. The write-up's most
important technical insight is that audio gives millisecond-precise event
timing; everything else should be built around that timeline. The three things
most likely to sink the project are not the applications but the foundation:
cross-phone clock synchronization, ball visibility from consumer phone cameras
at court distances, and the cost of ground-truth annotation. The plan below
front-loads those three so they are derisked before any application code is
written.

## Critical path

```
Sync + capture rig  →  court/camera calibration  →  acoustic events
      →  ball trajectory  →  player identity (wearable fusion)
      →  shot reconstruction + ontology  →  rally segmentation + outcome
      →  App A (teaching)  →  App B (longitudinal)  →  App C (patterns)
```

Applications B and C reuse everything A needs, so A is the natural first
product. Inside A, the recommended first vertical slice is the dink drill: the
ball is slow, the pro teaches it constantly, and its measurements (contact
height, net clearance, bounce depth) are exactly those in the write-up.

## First 30 days (no application code)

1. Week 1: record one session with four phones using the native camera app, a
   hand clap for sync and a tape measure for phone positions. Analyze offline in
   Python. This alone answers whether paddle impacts and bounces are cleanly
   separable in audio and how large the ball is in pixels from each position.
2. Weeks 2 and 3: build the minimal capture app (timestamps, chirp sync, Watch
   companion) and run the synchronization and calibration protocols.
3. Week 4: acoustic event detector v1 and the first annotated golden set.

See `02-implementation-plan.md` for the full sequence.
