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
| `06-reconciliation-with-sonicourt-app.md` | How documents 01–05 change in light of the existing `sonicourt-app` prototype (build 74): what is already built, what the plan gets wrong, revised phase status and the next three builds. Read this first if you know the prototype. |

## Read this first

Documents 01–05 were written from the concept write-up alone. The
`sonicourt-app` repository already contains a two-phone serve localization
prototype with chirp synchronization, automatic court calibration, a Watch
wrist logger and a month of field data. Document 06 reconciles the plan with
it and supersedes 01–05 wherever they differ. In short: Phases 0–2 are largely
done for two phones, the net-post camera layout replaces the plan's baseline
cameras, and the largest new ask of the phone app is continuous 1080p60
recording.

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

## First 30 days (revised in document 06)

1. Build 75: continuous 1080p60 recording beside the JPEG ring, scheduled-window
   chirp listening for drift, Watch target re-enabled, post id in session stamps.
2. Build 76 and one club session: two phones per post, calibration on both
   kitchen Ts, all four players wearing watches; wrist-to-acoustic matching
   run offline that evening.
3. Offline throughout: bounce and net-contact classes trained on the archived
   `.caf` files; first ball detector on the strike bursts; dink-drill trajectory
   fit against a string gauge at the net.

See `06-reconciliation-with-sonicourt-app.md` §3 and `02-implementation-plan.md`.
