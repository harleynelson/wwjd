// File: lib/dialogs/confirm_age_dialog.dart
// Purpose: Dialog to confirm the user's age before they can submit a prayer.
// This is a simple client-side confirmation.

import 'package:flutter/material.dart';

/// Shows a dialog to confirm the user is of a minimum age (e.g., 13+).
/// Returns `true` if the user confirms, `false` if they cancel or do not confirm.
Future<bool?> showConfirmAgeDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // User must explicitly choose an action.
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Age Confirmation'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('To submit a prayer, please confirm that you are 13 years of age or older.'),
              SizedBox(height: 8),
              Text('This helps us maintain a safe and appropriate community environment.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop(false); // User did not confirm.
            },
          ),
          FilledButton( // Using FilledButton for primary action emphasis.
            child: const Text('I Confirm (13+)'),
            onPressed: () {
              Navigator.of(dialogContext).pop(true); // User confirmed.
            },
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      );
    },
  );
}
