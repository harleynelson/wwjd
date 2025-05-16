const appVersion = '1.0.1';
const appName = 'Wake up with Jesus';
const appDescription = 'A daily devotional app to inspire and uplift your spirit.';

// text to speech
const defaultVoice = 'en-US-Chirp3-HD-Leda';


// --- Well of Hope Animation Constants ---
// Gentle Pulse Animation (for the main orb's subtle background breathing)
const int wellGentlePulseDurationMs = 3500;
const double wellGentlePulseMinScale = 0.98;
const double wellGentlePulseMaxScale = 1.02;

// Shimmer Effect Timing (for the "others are praying" flashes)
// This is the default/base duration for the AnimationController itself.
// Individual shimmers will have their duration randomized based on the min/random flash duration constants below.
const int wellShimmerBaseControllerDurationMs = 600; // A sensible default, e.g., average flash duration.

// --- Timing for scheduling shimmers (time *between* shimmers) ---
// Minimum pause duration after one shimmer ends and before the next one can start.
const int wellShimmerMinPauseMs = 500; // e.g., .5 seconds
// Maximum additional random pause duration.
// Total pause = wellShimmerMinPauseMs + random(0 to wellShimmerRandomPauseRangeMs)
const int wellShimmerRandomPauseRangeMs = 6500; // e.g., up to 6.5 more seconds (total .5s-7s pause)

// --- Duration of each individual shimmer flash ---
// Minimum duration for a single shimmer flash animation.
const int wellShimmerMinFlashDurationMs = 800; // e.g., 0.8 seconds
// Maximum additional random duration for that flash.
// Total flash duration = wellShimmerMinFlashDurationMs + random(0 to wellShimmerRandomFlashDurationRangeMs)
const int wellShimmerRandomFlashDurationRangeMs = 300; // e.g., up to 0.3 more seconds (total 0.8s-1.2s flash)


// --- Shimmer Visuals (used in _WellPainter) ---
// These control the appearance of each individual shimmer flash.

// Overall brightness/intensity multiplier for a flash
const double wellShimmerMinIntensityMultiplier = 0.6;
const double wellShimmerRandomIntensityMultiplierRange = 0.3; // Multiplier will be min + random(0 to range)

// Spread of the shimmer (as a factor of the orb's radius)
const double wellShimmerMinSpreadFactor = 0.85;
const double wellShimmerRandomSpreadFactorRange = 0.1; // Spread will be min + random(0 to range)

// Size of the bright core of the shimmer (as a factor of the shimmer's own spread)
const double wellShimmerMinCoreSizeFactor = 0.3;
const double wellShimmerRandomCoreSizeFactorRange = 0.2; // Core size will be min + random(0 to range)

// Base opacities for the shimmer gradient colors.
// These get further multiplied by the animation's effectStrength and the flashIntensityMultiplier.
const double wellShimmerColor1BaseOpacity = 0.45; // For the brightest color (e.g., white)
const double wellShimmerColor2BaseOpacity = 0.25; // For the middle color (e.g., cyanAccent)
const double wellShimmerColor3BaseOpacity = 0.15; // For the outer/fainter color (e.g., lightBlue)