# Slip-on identity band for paddles — invention notes

**Confidential and Subject to NDA.** Sonicourt / Invention Capital Partners. 2026-11-19. Builds on document 07 §1 (coloured bands) and feeds document 08 (inventory for the provisional) and document 14 (serve photo acquisition).

## 1. The constraints that shape the design

| Constraint | Consequence for the band |
|---|---|
| USA Pickleball 2.E.5: the only permitted alterations to a commercial paddle are edge guard tape, lead tape, changes to grip size or grip wrap, and identification markings; decals and tape may extend no more than 1.0 in above the top of the grip | The band must be a **grip accessory**: it sits on the grip, and anything that rises above the top of the grip stays within 1.0 in. Nothing touches the face or edge guard. |
| 2.E.2 / 2.E.6: no adversely reflective surface; manufacturers' compliance summaries read this as no reflective or sparkling materials on face, edge guard or handle, gloss at or below 80 GU | **Matte** finish, **no retroreflective** material, no metallic or glitter pigment. Daylight-fluorescent pigment is allowed (it is bright, not reflective) but must be tested for "distraction" with players. |
| Must not distract players | Small colour area, placed where the hand and body hide it from the opponent most of the time, in colours already common on overgrips. The band should look like a grip accessory, not a target. |
| Camera pixel budget (document 14 §2): about 11 px per inch in the 12 MP still at the baseline, 5 px per inch in the video frame | Each colour element at least 0.5 in along the handle, so the still sees 5 px or more per element; the band carries **two to three elements**, not one. |
| Any azimuth: the paddle is held at an unknown rotation about its handle axis | Code elements are **full rings** around the handle, so the pattern is the same from every direction. |
| Indoor LED and dusk colour shifts | A **reference ring** of known white and black is part of the band, so each photo is colour-corrected on the band itself. |
| Low cost, made in China, branded | Single moulded silicone part or a thin sleeve with pre-coloured rings; existing wristband and phone-grip tooling; target cost under US $0.30 per band in quantity. |

## 2. The design: a ring-coded grip collar

A silicone sleeve, 1.5 to 2.0 in long, 1.5 to 2 mm thick, that stretches over the top of the grip (handle circumference 4.0 to 4.5 in, 30 % stretch). Reading from the paddle face downward:

1. **Collar.** A slightly raised lip, 2 to 3 mm, at the top edge of the grip, within the 1.0 in allowance. It gives the camera a **silhouette feature** at the handle-to-face junction that survives when colour fails (edge-on paddle, poor light), and it gives the player a **tactile index stop** for hand position, which is a genuine grip function and keeps the product in the grip-wrap category.
2. **Reference ring.** 0.5 in of matte white with a thin black line. It is the white balance and exposure patch for the photo, and a **scale bar**: its known width gives the distance to the paddle, and with the collar's known diameter gives the paddle's tilt. This is what turns the band from a colour tag into a metric marker for paddle pose and, later, swing speed from the 60 fps clips.
3. **Code rings.** Two rings of 0.5 to 0.6 in, each in one of four matte colours chosen away from court blue and green, ball yellow and skin: orange, magenta, violet, black. Two rings from four colours give 16 identities; three rings give 64. A club set of four bands uses four codes that differ in both rings, so a single mis-read colour never maps to another player in the set.
4. **Branding.** SONICOURT debossed into the silicone in the same colour (no colour contrast, so it adds nothing to the camera and nothing to the opponent's eye).

Variants to prototype with tape in the 105 driveway run (document 14 §3): single colour 1 in, single colour 2 in, stacked two-colour, fluorescent 2 in, control. The ring-code design is the stacked variant with a white reference added; tape mock-ups of it are easy.

## 3. Why it can be patentable

Prior art found so far: colour-coded bands on racket handles for **string tension** (US 7,335,120) and **grip position** indicator bands with tactile or printed cues. None found for camera-read player identity with the features below. A proper search is still needed before filing.

Distinct from that art, and claimable in combination with the Sonicourt system:

- **Azimuth-invariant optical code on a grip sleeve:** identity encoded in the axial sequence of full circumferential rings, readable from any rotation of the handle, with element widths sized to the imaging distance.
- **Integrated colorimetric reference:** a white and black ring on the same sleeve used to colour-correct the code rings in the same image, so the code is read under arbitrary lighting without per-session enrolment.
- **Metric marker:** the known ring widths and collar diameter used to recover paddle distance and tilt from a single image, and paddle speed from consecutive frames.
- **Dual-function collar:** the raised lip serving as both a tactile grip index for the player and a silhouette feature for the detector.
- **System claims:** the code read from a high-resolution still triggered by a spoken word and a feet-behind-baseline pose while video continues; the identity fused with the wrist spike and acoustic side; the doubles position state updated per attributed hit; a code-to-name table set once per set of bands (the app reads the code; the player only taps their name on first use).
- **Manufacturing claims (weaker but cheap to add):** multi-colour silicone sleeve made by over-moulding pre-coloured rings or by two-shot moulding, with debossed branding in the body colour.

Recommended protection: include the band and the system claims in the next provisional (document 08 claim family on attribution), a **design patent** on the band's appearance, and a trademark filing for SONICOURT in class 28 (sporting goods) alongside the software class.

## 4. What the players and the associations see

- A grip accessory in overgrip colours, mostly under or just above the hand. Tennis and pickleball overgrips in orange, pink and white are common, so the look is familiar.
- No effect on the hitting surface, weight distribution (about 5 g), paddle length or width.
- If an association ever objects, the fallback is the same code on the **grip wrap itself** (a printed overgrip), which is explicitly permitted. The detector does not care which carrier holds the rings.

## 5. Open questions the serve photos must answer (document 14)

1. Real pixels per inch at the baseline per phone and whether 0.5 in rings give 5 px.
2. Which of orange, magenta, violet, black separate under sun, shade and indoor LED after white-balancing on the reference ring.
3. How often the hand covers the top 1.5 in of the grip in the "paddle up" pose and in rally frames; whether the collar is still visible when the rings are not.
4. Whether fluorescent pigment is needed at all, or matte saturated colours suffice. Fluorescent is the fallback, not the default, because of the distraction question.

## 6. Manufacturing path (for later)

Silicone wristband factories (Shenzhen, Dongguan) quote multi-colour segmented bands at a few cents to US $0.30 at 5,000 to 10,000 units, with one-time tooling in the low hundreds of dollars per mould. Debossed logo is standard. Specify: 60 to 70 Shore A, matte texture, pigments by Pantone with a gloss limit, food-grade silicone to avoid skin issues, and a colour QC by photographing each batch against the reference ring under a fixed light. First order: 200 bands in four codes for club tests.
