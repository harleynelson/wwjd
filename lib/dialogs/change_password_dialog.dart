// File: lib/dialogs/change_password_dialog.dart
// Path: lib/dialogs/change_password_dialog.dart
import 'package:flutter/material.dart';
import 'package:wwjd_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

void showChangePasswordDialog({
  required BuildContext context,
  required AuthService authService,
}) {
  final formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder( // Use StatefulBuilder to manage loading state within dialog
        builder: (stfContext, stfSetState) {
          return AlertDialog(
            title: const Text("Change Password"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPasswordController,
                    decoration: const InputDecoration(labelText: "Current Password"),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your current password.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(labelText: "New Password"),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a new password.";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(labelText: "Confirm New Password"),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please confirm your new password.";
                      }
                      if (value != newPasswordController.text) {
                        return "Passwords do not match.";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          stfSetState(() => isLoading = true);
                          try {
                            await authService.updateUserPassword( // Method to be created in AuthService
                              currentPasswordController.text,
                              newPasswordController.text,
                            );
                            if (Navigator.of(dialogContext).canPop()) {
                                Navigator.of(dialogContext).pop();
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Password changed successfully."), backgroundColor: Colors.green),
                            );
                          } on fb_auth.FirebaseAuthException catch (e) {
                             String message = "Failed to change password.";
                             if (e.code == 'wrong-password') {
                               message = "Incorrect current password.";
                             } else if (e.code == 'weak-password') {
                               message = "The new password is too weak.";
                             } else if (e.code == 'requires-recent-login') {
                               message = "This action requires a recent sign-in. Please sign out and sign back in.";
                             }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("An unexpected error occurred: ${e.toString()}"), backgroundColor: Theme.of(context).colorScheme.error),
                            );
                          } finally {
                            if(dialogContext.mounted) { // Check if dialog context is still mounted
                               stfSetState(() => isLoading = false);
                            }
                          }
                        }
                      },
                child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Change Password"),
              ),
            ],
          );
        }
      );
    },
  );
}