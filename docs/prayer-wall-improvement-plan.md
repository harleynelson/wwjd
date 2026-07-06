# Prayer Wall of Hope — Improvement Plan

> Created: 2026-07-06

## Current State Assessment

| Component | Quality | Issues |
|---|---|---|
| **Well of Hope** (CustomPaint orb) | 🟢 Good | Pulse + shimmer + mote particles are solid. Could use richer glow and light rays. |
| **River Prayer Items** | 🟡 Okay | Glassmorphism cards with breathing amber glow. Feels like floating cards, not a "river." |
| **Mystical Embers** | 🟡 Okay | Rising dots only. No layering, no sparkle variety. |
| **Animated Prayer Mote** | 🟡 Okay | Simple cyan dot flying to well. No trail, no particle burst on arrival. |
| **Prayer Streak Display** | 🔴 Weak | Plain text + fire icon. Feels tacked on. |
| **PageView Transitions** | 🔴 Weak | Standard slide. Cards peek in from edges (viewportFraction 0.75), breaking immersion. |
| **Overall Atmosphere** | 🟡 Okay | Dark gradient + embers. Missing: starfield, divine light rays, water reflection, ambient audio. |

---

## Priority Fixes (ordered by visual impact)

### 1. 🔥 Add a "River of Light" Background Effect — *Highest Impact*

**Problem:** Despite being called "River Prayer Items," there's no river. Cards float in dark space.

**Solution:** Add a flowing, horizontal river of light behind the PageView area. A shimmering band of teal/gold that slowly animates left-to-right, with "prayer cards" appearing to float on its surface.

- [ ] Create `RiverOfLightBackground` widget using `CustomPaint`
- [ ] Animated flowing gradient (teal → gold → teal) with sinusoidal wave distortion
- [ ] Add subtle water ripple/caustic light effect under prayer cards
- [ ] Layer behind PageView but above the dark gradient

### 2. 🔥 Celestial Header — Divine Light Rays + Starfield

**Problem:** Top of screen (behind Well) is just a dark gradient. No heavenly feel.

**Solution:** Add animated light rays emanating from behind the Well, like divine light breaking through clouds. Add subtle twinkling stars above.

- [ ] Create `CelestialLightRays` widget — radial light beams behind the well, slowly rotating
- [ ] Add `StarfieldBackground` with small twinkling white/gold dots
- [ ] Layer: Starfield → Light Rays → Well → Embers

### 3. 🔥 Redesign Prayer Item Cards — "Floating Lanterns"

**Problem:** Cards look like generic glassmorphism UI cards, not magical religious artifacts.

**Solution:** Redesign as "floating prayer lanterns" — parchment-like warm glow, with subtle floating light particles orbiting each card. A gentle bobbing animation (like floating on water).

- [ ] Add `customPainter` for lantern-shaped glow behind each card
- [ ] Replace glass gradient with warm parchment/scroll aesthetic (cream → gold)
- [ ] Add 2-3 small orbiting light motes per card
- [ ] Add subtle vertical bobbing animation (floating on water)
- [ ] Replace `Icons.light_mode_outlined` with a small cross or dove icon

### 4. Replace PageView Slide with Crossfade Dissolve

**Problem:** viewportFraction 0.75 shows clipped partial cards on edges. Looks janky.

**Solution:** Switch to a full-width single-card display with a crossfade dissolve transition. Or keep PageView but use `viewportFraction: 1.0` and add a custom `PageTransitionsBuilder` with a dissolve.

- [ ] Change `viewportFraction` to `1.0`
- [ ] Add `fadeTransition` PageTransitionsBuilder or switch to `AnimatedSwitcher` with dissolve
- [ ] Keep swipe gesture but with smooth fade instead of slide

### 5. Upgrade the Animated Prayer Mote

**Problem:** Simple cyan dot. Not dramatic enough for "sending a prayer."

**Solution:** Turn it into a glowing particle with a comet-like trail. Add a small burst of light particles when it reaches the well.

- [ ] Add trailing particle effect (2-3 trailing smaller motes)
- [ ] Change from cyan dot to warm gold/white glowing orb
- [ ] Add particle burst on well arrival (8-12 tiny particles scatter briefly)

### 6. Redesign Prayer Streak Display

**Problem:** Plain text row with fire emoji. Feels like an afterthought.

**Solution:** Make it a beautiful, integrated banner — perhaps a thin glowing ribbon or an illuminated scroll banner with the streak count, styled like an illuminated manuscript header.

- [ ] Wrap in a decorated container with gold filigree-like borders
- [ ] Add a subtle continuous shimmer animation across the text
- [ ] Display flame icons that grow in intensity with streak length
- [ ] Add "Total prayers lifted: X" as a smaller subtitle

### 7. Enhance Mystical Embers Background

**Problem:** Only one type of particle — rising dots.

**Solution:** Add variety — larger sparkles that twinkle, some that drift sideways, occasional bright "firefly" bursts. Layer two ember systems (slow/fast).

- [ ] Add a second ember layer with faster, smaller particles
- [ ] Add occasional bright sparkle bursts (random 1-3 particles that flare bright then fade)
- [ ] Vary ember colors: gold, warm white, soft amber

### 8. Add Ambient Audio (Optional but High Impact)

**Problem:** Silent. No sensory immersion.

**Solution:** Add a subtle looping ambient audio track — gentle water sounds, distant choir hum, soft wind. Very low volume, toggleable.

- [ ] Add audio file asset (water + soft pad)
- [ ] Use existing `audioplayers` package for low-volume loop
- [ ] Add mute toggle in corner of screen
- [ ] Respect device silent mode

---

## Files to Create

| File | Purpose |
|---|---|
| `lib/widgets/prayer_wall/river_of_light_background.dart` | Flowing river light effect |
| `lib/widgets/prayer_wall/celestial_light_rays.dart` | Divine light rays from behind well |
| `lib/widgets/prayer_wall/starfield_background.dart` | Twinkling star particles |

## Files to Modify

| File | Changes |
|---|---|
| `lib/screens/prayer_wall/prayer_wall_screen.dart` | Layer new backgrounds, switch to dissolve transition, integrate ambient audio |
| `lib/widgets/prayer_wall/river_prayer_item.dart` | Redesign as floating lantern, add orbiting motes, bobbing animation |
| `lib/widgets/prayer_wall/animated_prayer_mote.dart` | Add comet trail, arrival particle burst, gold color |
| `lib/widgets/prayer_wall/prayer_streak_display.dart` | Redesign as illuminated manuscript banner |
| `lib/widgets/prayer_wall/mystical_embers_background.dart` | Add second layer, sparkle bursts, color variety |

---

## Visual Target

Imagine:
- **Top third:** Twinkling stars fade into divine golden light rays streaming from behind a softly pulsing luminous orb (the Well). Floating embers drift upward like prayers rising.
- **Middle third:** A flowing river of soft teal-gold light, with warm parchment "prayer lanterns" gently bobbing on its surface, each surrounded by tiny orbiting light motes. Only one lantern visible at a time, dissolving into the next.
- **Bottom third:** An illuminated manuscript-style banner showing the streak. A subtle "Share a Prayer" button floats at the bottom.
- **Sound:** Very quiet water + distant choir pad looping.
