// File: lib/dialogs/password_prompt_dialog.dart
// Path: lib/dialogs/password_prompt_dialog.dart
import 'package:flutter/material.dart';

/// Shows a dialog to prompt the user for their password.
///
/// [context]: The build context.
/// [email]: The email of the user for whom the password is being requested,
///          displayed in the dialog for context.
/// Returns a Future<String?> which completes with the entered password,
/// or null if the dialog is cancelled or no password entered.
Future<String?> showPasswordPromptDialog(BuildContext context, String email) async {
  final passwordController = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Link Google to Existing Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'To link your Google account with your existing account for $email, please enter your password.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Password', border: OutlineInputBorder()),
              autofocus: true,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(dialogContext).pop(null);
            },
          ),
          TextButton(
            child: const Text('Link Account'),
            onPressed: () {
              Navigator.of(dialogContext).pop(passwordController.text);
            },
          ),
        ],
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      );
    },
  );
}