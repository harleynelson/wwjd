// File: lib/screens/premium_screen.dart
// New File

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart'; // For ProductDetails
import '../services/iap_service.dart';
import '../services/auth_service.dart'; // To check current premium status
import '../models/app_user.dart';     // To check current premium status

class PremiumScreen extends StatelessWidget {
  static const routeName = '/premium';

  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iapService = Provider.of<IAPService>(context);
    final appUser = Provider.of<AppUser?>(context); // Get AppUser for current status

    bool isCurrentlyPremium = appUser?.isPremium ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isCurrentlyPremium) ...[
              Card(
                elevation: 2,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.workspace_premium_rounded, size: 48, color: Theme.of(context).colorScheme.onPrimaryContainer),
                      const SizedBox(height: 12),
                      Text(
                        'You are already a Premium User!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                       Text(
                        'Thank you for your support. All premium features are unlocked.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              'Unlock All Features with WWJD Premium!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildFeatureListItem(context, Icons.lock_open_rounded, 'Access all Reading Plans'),
            _buildFeatureListItem(context, Icons.volume_up_rounded, 'Unlock all TTS Narration Voices'),
            _buildFeatureListItem(context, Icons.forum_rounded, 'Unlimited Prayer Wall Submissions'),
            _buildFeatureListItem(context, Icons.no_encryption_gmailerrorred_rounded, 'Ad-Free Experience (if ads are introduced)'),
            _buildFeatureListItem(context, Icons.new_releases_rounded, 'Early Access to New Features'),
            const SizedBox(height: 24),
            if (iapService.isLoadingProducts)
              const Center(child: CircularProgressIndicator())
            else if (!iapService.isStoreAvailable)
              const Center(child: Text('In-App Purchases are currently unavailable.'))
            else if (iapService.products.isEmpty)
              const Center(child: Text('No premium products found. Please try again later.'))
            else
              ...iapService.products.map((product) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Icon(Icons.shopping_cart_checkout_rounded, color: Theme.of(context).colorScheme.primary, size: 32),
                    title: Text(product.title, style: Theme.of(context).textTheme.titleLarge),
                    subtitle: Text(product.description, style: Theme.of(context).textTheme.bodySmall),
                    trailing: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: iapService.isPurchasing
                          ? null // Disable button if a purchase is already in progress
                          : () {
                              if (!isCurrentlyPremium) { // Only allow purchase if not already premium
                                iapService.buyProduct(product);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("You are already a premium user!"))
                                );
                              }
                            },
                      child: iapService.isPurchasing 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isCurrentlyPremium ? "Unlocked" : product.price),
                    ),
                  ),
                );
              }).toList(),
            const Spacer(), // Pushes restore button to bottom if content is short
            if (iapService.isStoreAvailable && !isCurrentlyPremium) // Only show restore if not premium
              TextButton.icon(
                icon: const Icon(Icons.restore_rounded),
                label: const Text('Restore Purchases'),
                onPressed: () {
                  iapService.restorePurchases();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureListItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
