# WWJD App — Monetization Roadmap

> Created: 2026-07-06

## Current State

- **One-time purchase only** (`com.alpentor.wwjd.premium.unlock.permanent`)
- Subscription product IDs exist in `iap_constants.dart` but are commented out
- Premium gates: some reading plans, some TTS voices, Prayer Wall limits
- Premium screen messaging is strong ("Partner with Us," "Support the Mission")

---

## Priority Roadmap

### 1. 🔥 Add Subscriptions (Monthly + Yearly) — *Biggest Revenue Lever*

**Status:** not-started

A one-time purchase caps lifetime value per user. Subscriptions create recurring revenue.

- [ ] Uncomment and implement monthly/yearly subscription IDs in `lib/config/iap_constants.dart`
- [ ] Create subscription products in App Store Connect & Google Play Console
- [ ] Offer both on `PremiumScreen` with yearly ~20% discount vs monthly
- [ ] Keep lifetime purchase as high-priced anchor ($49–$99)
- [ ] Highlight "Most Popular" badge on yearly plan

**Pricing strategy:**
```
Monthly:   $4.99/mo
Yearly:    $39.99/yr  ($3.33/mo — "Most Popular")
Lifetime:  $79.99      (anchor)
```

---

### 2. 🔥 Add Free Trial (3–7 Days)

**Status:** not-started

No friction to experience premium. Users who try premium features are far more likely to convert.

- [ ] Configure introductory offers in App Store Connect / Google Play Console
- [ ] Add trial eligibility check in `IAPService`
- [ ] Show "Start Your Free Trial" CTA on `PremiumScreen`

---

### 3. 📱 Gate Core Features More Aggressively

**Status:** not-started

Current premium features are too narrow. Expand what premium unlocks.

| Feature | Free Tier | Premium |
|---|---|---|
| Reading Plans | 3 free plans | All 20+ plans |
| TTS Narration | 1 voice, standard quality | All voices + Neural2/Wavenet |
| Prayer Wall | 1 prayer/day | Unlimited |
| Verse Image Generator | Watermarked | HD, no watermark |
| Devotionals | Today only | Full archive access |
| Favorites | 10 verses | Unlimited |
| Ad-Free | — | No ads |

- [ ] Mark more reading plan JSONs as `isPremium: true`
- [ ] Add premium watermark to verse image generator for free users
- [ ] Enforce Prayer Wall daily limit for free users
- [ ] Add favorites cap for free users
- [ ] Gate TTS voice quality tiers

---

### 4. 🪙 Add "Tip Jar" / Donation Option

**Status:** not-started

Uniquely suited to faith-based apps. Pure incremental revenue.

- [ ] Add "Support This Ministry" section to `PremiumScreen`
- [ ] Suggested amounts: $5, $10, $25, Custom
- [ ] Implement as consumable IAP products
- [ ] Add small non-intrusive donate button elsewhere (e.g., Settings)

---

### 5. 📊 Soft Paywall Triggers (Usage-Based)

**Status:** not-started

Instead of hard paywalls, use soft limits that trigger upgrade prompts:

- [ ] "You've read 3 free plans — unlock unlimited with Premium"
- [ ] "You've used 10 TTS plays this month — subscribe for unlimited"
- [ ] Streak-based: "Maintain your 7-day streak with Premium"

---

### 6. 🎯 Home Screen Premium Upsell

**Status:** not-started

Home screen has no premium teaser currently.

- [ ] Add non-intrusive premium card/banner to `HomeScreen`
- [ ] Show locked reading plan teaser: "Unlock all 20+ guided journeys →"
- [ ] Show when user is not premium; hide when premium

---

### 7. 📧 Abandoned Premium Page Push Notification

**Status:** not-started

- [ ] Track when user visits `PremiumScreen` via Firebase Analytics
- [ ] Send push via FCM 24h later if no purchase: "Start your free 7-day trial"
- [ ] Respect notification preferences

---

### 8. 🌐 Family/Church Group Plan

**Status:** not-started

- [ ] "Family Plan" ($7.99/mo for up to 6 members)
- [ ] "Church Group" tier with shared reading plans & prayer groups
- [ ] Drives organic growth through sharing

---

## Quick Wins (Low Effort)

- [ ] Uncomment subscription IDs in `lib/config/iap_constants.dart`
- [ ] Add premium teaser card to `lib/screens/home_screen.dart`
- [ ] Add tip jar to `lib/screens/premium_screen.dart`
- [ ] Increase premium plan count (mark more JSONs as `isPremium: true`)
- [ ] Add subscription product IDs to app store consoles

---

## Files to Modify

| File | Changes |
|---|---|
| `lib/config/iap_constants.dart` | Add subscription product IDs |
| `lib/screens/premium_screen.dart` | Subscription tiers, free trial CTA, tip jar |
| `lib/services/iap_service.dart` | Subscription purchase logic, trial handling |
| `lib/screens/home_screen.dart` | Premium teaser banner |
| `lib/services/prayer_service.dart` | Enforce daily limit for free users |
| `lib/services/text_to_speech_service.dart` | Voice quality tiers |
| `lib/screens/verse_image_generator_screen.dart` | Watermark for free users |
| Multiple reading plan JSONs | Mark as `isPremium: true` |

---

## Notes

- Premium screen already uses great "Partner with Us" / "Support the Mission" framing — keep this
- Subscriptions align perfectly with the "ongoing partnership" messaging
- Keep existing one-time purchase as an anchor/high-end option
