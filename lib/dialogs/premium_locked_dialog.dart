// File: lib/dialogs/premium_locked_dialog.dart
// Updated: "Joel Osteen meets Mr. Rogers" vibe—warm, inviting, and ministry-focused.

import 'package:flutter/material.dart';
import '../screens/premium_screen.dart';

class PremiumLockedDialog extends StatelessWidget {
  final String featureName;

  const PremiumLockedDialog({
    super.key,
    required this.featureName,
  });

  static Future<void> show(BuildContext context, {required String featureName}) {
    return showDialog(
      context: context,
      builder: (context) => PremiumLockedDialog(featureName: featureName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Row(
        children: [
          // Changed from a harsh lock to a "gift/offering" icon
          Icon(Icons.volunteer_activism_rounded, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Text(
            "A Special Invitation",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, friend! We are so glad you're here.",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "You've discovered something wonderful. The $featureName feature is reserved for our Premium family—a tool designed to help you go deeper in your daily walk and find new strength.",
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              "Would you consider joining us in the full experience today? It unlocks every blessing in the app and helps support this ministry to reach more neighbors just like you.",
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurfaceVariant,
          ),
          child: const Text("Not right now"),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.pushNamed(context, PremiumScreen.routeName);
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          icon: const Icon(Icons.star_rate_rounded, size: 18),
          label: const Text("Unlock Blessings"),
        ),
      ],
    );
  }
}