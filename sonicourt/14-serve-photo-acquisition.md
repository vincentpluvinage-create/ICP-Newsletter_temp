# Serve photos — acquisition and analysis before any band code

**Confidential and Subject to NDA.** Sonicourt / Invention Capital Partners. 2026-11-19.

Decision (Vincent, 11/19): acquire real serve photos first and analyze them; no further code for the paddle band until the pictures say what a band needs to look like.

## 1. What the app already produces (build 104.9, unchanged in 105)

- The word "serving" arms the serving side's two phones. Each takes a 12 MP JPEG still when a person stands with both feet behind the half-baseline, or after 3 s without one.
- Files on each phone, swept to the iPad by the collect and then to the Mac:
  `<rec>-servephoto<k>-p<slot>.jpg` (full still) and `<rec>-servephoto<k>-p<slot>-crop.jpg` (crop around the person seen in the video frame).
- Pad log line per photo: `SERVE-PHOTO k · WxH · why · feet · waited · shutter ms · video gap ms · crop · kB`.
- In 105 the camera runs a 1080p60 format. The still size that format allows is printed in the CAMERA line at start (`→ WxH`). **Check it is 4032x3024 (12 MP) and not 1920x1080** before relying on the photos for band work; `pick60` prefers the format with the largest still but field of view weighs more in its score.

## 2. Geometry: what a band can occupy in the picture

Phones at the net posts, server at the baseline, 22 ft from the net. Lens to server about 23 ft (276 in). Horizontal field about 69° on the wide camera.

| Quantity | 12 MP still (4032 px wide) | 1080p video frame |
|---|---|---|
| Field width at the server | about 380 in | about 380 in |
| Pixels per inch at the server | about 10.6 | about 5.1 |
| 1 in wide band on the handle | 11 px | 5 px |
| 2 in wide band | 21 px | 10 px |
| Pickleball (2.9 in) | 31 px | 15 px |
| Paddle face (8 in) | 85 px | 41 px |

So a single 1 in band is a thin 11 px stripe in the still and unusable in the video frame. Any band design must be read from the still, and a 2 in band or two stacked colours is the minimum worth testing. These are estimates; the photos give the real numbers.

## 3. Acquisition protocol (no code change)

**A. Push the existing photos.** The 11/17 driveway run of 104.9 produced serve photos; they are on the Mac. Copy every `*servephoto*.jpg` and its pad log into `sonicourt-app/TESTING/serve-photos-104.9/` and push (JPEGs are small; the repo takes them). This gives the first real numbers for §2 with no new session.

**B. Driveway run of 105 (runbook blocks 1–5) with band prototypes.** While running the acceptance tests, wrap the two paddle handles with painter's tape or electrical tape in these variants, one variant per rally block, and say "serving" before each serve so a photo is taken each time:
1. One colour, 1 in wide (baseline): red on one paddle, blue on the other.
2. One colour, 2 in wide.
3. Two stacked colours, 1 in each (red over white, blue over white).
4. Fluorescent (orange or green) tape, 2 in.
5. Control: no tape.

Repeat each variant from both halves of the baseline (left and right of the centre line) and once with the paddle held low. Ten photos per variant per phone is plenty. Note the time and variant on paper or in the pad log (tap NOTE if available) so the photos can be labelled.

**C. Lighting.** Shoot at least once in low sun and once in shade or dusk; the club courts on 11/16 were indoors under LED, which is the hardest case for colour.

**D. Transfer.** Collect at FINISH, copy the `servephoto` JPEGs and pad logs to `TESTING/serve-photos-105-<date>/` on the Mac, push to GitHub.

## 4. Analysis (done here, from the pushed JPEGs)

1. Measured pixel size of handle, band, paddle face and ball at the baseline, per phone, versus the §2 estimates.
2. Colour separability: hue and saturation of each band variant against skin, clothing, court, net and fence, in each lighting; which variants survive indoor LED.
3. Band visibility by pose: how often the hand covers the band when the paddle is "up"; whether a band at the handle butt or on the paddle neck is more visible.
4. Ball visibility in the still: how often the ball is in frame and separable from the background at serve.
5. Feet gate quality: how often both feet are behind the line when the still fires, and the waited and shutter times from the log.
6. Output: a short table of variants with a go or no-go, and the pixel budget a detector would have. That is the input for a build 106 design, not before.

## 5. Mac session command (paste as is)

```
In the sonicourt-app repo: find every file matching *servephoto*.jpg and every pad log from the 11/17 driveway run of build 104.9 in the TESTING roots on this Mac, copy them into TESTING/serve-photos-104.9/ with a README listing the source paths, date and build; commit and push to main. Do not add any .caf or .mov files.
```
