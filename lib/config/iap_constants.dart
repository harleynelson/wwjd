// File: lib/config/iap_constants.dart
// New File

// Define your product IDs as configured in the app stores.
// These are examples. Replace with your actual IDs.

// Non-consumable (Unlock all premium features)
const String kProductIdPremiumUnlock = 'com.alpentor.wwjd.premium.unlock.permanent'; // Example for one-time purchase

// Subscriptions (Examples if you choose this route)
// const String kProductIdSubscriptionMonthly = 'com.alpentor.wwjd.premium.monthly';
// const String kProductIdSubscriptionYearly = 'com.alpentor.wwjd.premium.yearly';

// A set of all product IDs you want to query from the stores.
const Set<String> kProductIds = {
  kProductIdPremiumUnlock,
  // Add subscription IDs here if you use them
  // kProductIdSubscriptionMonthly,
  // kProductIdSubscriptionYearly,
};
