// File: lib/screens/premium_screen.dart
// Updated: Rewrote copy to be warm, inviting, and ministry-focused ("Support the Mission" vibe).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart'; 
import 'dart:io'; // For Platform check
import '../services/iap_service.dart';
import '../models/app_user.dart';     

class PremiumScreen extends StatefulWidget {
  static const routeName = '/premium';

  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Optional: Logic to clear errors in service if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    final iapService = Provider.of<IAPService>(context);
    final appUser = Provider.of<AppUser?>(context); 

    bool isCurrentlyPremium = appUser?.isPremium ?? false;
    final theme = Theme.of(context);

    // Show error snackbar if service reports an error
    if (iapService.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(iapService.error!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner with Us'), // Changed from "Go Premium"
      ),
      body: Stack(
        children: [
          SingleChildScrollView( // Added scroll view for smaller screens
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (isCurrentlyPremium) ...[
                  Card(
                    elevation: 2,
                    color: theme.colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(Icons.volunteer_activism_rounded, size: 48, color: theme.colorScheme.onPrimaryContainer),
                          const SizedBox(height: 12),
                          Text(
                            'You are a Vital Partner!',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thank you for supporting this ministry. Because of you, we can reach more neighbors with the Good News.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.9),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Welcoming Header
                Text(
                  'Deepen Your Walk with WWJD Premium',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your support helps keep this sanctuary peaceful and available for everyone.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Feature List - Warmed up wording
                _buildFeatureListItem(context, Icons.library_books_rounded, 'Access our full library of guided scripture journeys'),
                _buildFeatureListItem(context, Icons.record_voice_over_rounded, 'Listen to God\'s word with all our soothing narrators'),
                _buildFeatureListItem(context, Icons.favorite_rounded, 'Share your heart freely on the Prayer Wall without limits'),
                _buildFeatureListItem(context, Icons.spa_rounded, 'Enjoy a peaceful, distraction-free environment (Ad-Free)'),
                _buildFeatureListItem(context, Icons.handshake_rounded, 'Directly support future updates and new tools'),
                
                const SizedBox(height: 32),
                
                // --- PRODUCT LIST ---
                if (!iapService.isStoreAvailable)
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Text(
                      'The store is taking a moment of rest.\nPlease try again shortly.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                    ),
                  )
                else if (iapService.products.isEmpty && !iapService.isLoading)
                   Column(
                     children: [
                       const Text('We couldn\'t find the offering options right now.'),
                       TextButton(onPressed: iapService.loadProducts, child: const Text("Refresh"))
                     ],
                   )
                else
                  ...iapService.products.map((product) {
                    return Card(
                      elevation: 4,
                      shadowColor: theme.colorScheme.shadow.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          radius: 24,
                          child: Icon(Icons.star_rate_rounded, color: theme.colorScheme.onSecondaryContainer),
                        ),
                        title: Text(product.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(product.description, style: theme.textTheme.bodySmall),
                        ),
                        trailing: FilledButton(
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: (iapService.isLoading || isCurrentlyPremium)
                              ? null 
                              : () => iapService.buyProduct(product),
                          child: Text(isCurrentlyPremium ? "Partnered" : product.price),
                        ),
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 24), // Spacer
                
                // --- RESTORE & REDEEM BUTTONS ---
                if (iapService.isStoreAvailable && !isCurrentlyPremium)
                  Column(
                    children: [
                      if (Platform.isIOS)
                        TextButton(
                          onPressed: iapService.isLoading ? null : iapService.presentCodeRedemptionSheet,
                          child: const Text('Redeem Gift Code'),
                        ),
                      TextButton.icon(
                        icon: const Icon(Icons.restore_rounded, size: 18),
                        label: const Text('Restore My Partnership'),
                        style: TextButton.styleFrom(foregroundColor: theme.colorScheme.secondary),
                        onPressed: iapService.isLoading ? null : iapService.restorePurchases,
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // --- FULL SCREEN LOADER OVERLAY ---
          if (iapService.isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureListItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align top for multi-line text
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text, 
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}