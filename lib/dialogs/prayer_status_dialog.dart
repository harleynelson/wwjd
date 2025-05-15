// File: lib/dialogs/prayer_status_dialog.dart
// Path: lib/dialogs/prayer_status_dialog.dart
// Method: showPrayerStatusDialog (updated part)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard functionality.

/// Shows a dialog indicating the success or failure of a prayer submission.
/// If successful, displays the [prayerId] and [submitterAnonymousId] for tracking.
/// Returns a Future that completes when the dialog is dismissed.
Future<void> showPrayerStatusDialog(
  BuildContext context, {
  required bool success,
  String? prayerId, 
  String? submitterAnonymousId, 
  String? message, 
}) {
  return showDialog<void>( 
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(success ? 'Prayer Submitted' : 'Submission Failed'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                message ?? 
                    (success
                        ? 'Your prayer has been sent for review by our team.'
                        : 'We could not submit your prayer at this time. Please try again later.'),
              ),
              if (success && submitterAnonymousId != null && submitterAnonymousId.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Your Anonymous Prayer ID:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8), // Increased spacing for better readability
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
                  children: [
                    // Use SelectableText to allow copying and ensure full ID is visible (wraps if needed)
                    Expanded(
                      child: SelectableText(
                        submitterAnonymousId,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                        // textAlign: TextAlign.start, // Default, but explicit
                      ),
                    ),
                    // Keep the copy button, but it's less critical if SelectableText is used.
                    // Users can long-press SelectableText to copy.
                    IconButton(
                      icon: const Icon(Icons.copy_outlined, size: 20),
                      tooltip: 'Copy ID',
                      padding: EdgeInsets.zero, // Reduce padding for compact layout
                      constraints: const BoxConstraints(), // Reduce constraints for compact layout
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: submitterAnonymousId));
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text('Anonymous ID copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    )
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'You can use this ID on the "My Submitted Prayers" screen to see interactions with your prayer (once approved). Your prayer remains anonymous on the public wall.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ]
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(dialogContext).pop(); 
            },
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      );
    },
  );
}
