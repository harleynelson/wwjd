// File: lib/widgets/settings/account_section_widget.dart
// Path: lib/widgets/settings/account_section_widget.dart
import 'package:flutter/material.dart';
import 'package:wwjd_app/models/app_user.dart';
import 'package:wwjd_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../dialogs/change_password_dialog.dart'; // Will be created next

// Dialog for re-authentication if needed for deletion (remains here for delete logic)
Future<String?> _showReauthPasswordDialog(BuildContext context, String email) async {
  final passwordController = TextEditingController();
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Re-authenticate to Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('For security, please re-enter your password for $email to continue with account deletion.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
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
            child: const Text('Re-authenticate'),
            onPressed: () {
              Navigator.of(dialogContext).pop(passwordController.text);
            },
          ),
        ],
      );
    },
  );
}


class AccountSectionWidget extends StatefulWidget {
  final AppUser? appUser;
  final VoidCallback onSignInWithGoogle;
  final VoidCallback onSignInWithEmail;
  final VoidCallback onToggleSignUpMode;
  final VoidCallback onSignOut;
  final bool isSignUpMode;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const AccountSectionWidget({
    super.key,
    required this.appUser,
    required this.onSignInWithGoogle,
    required this.onSignInWithEmail,
    required this.onToggleSignUpMode,
    required this.onSignOut,
    required this.isSignUpMode,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<AccountSectionWidget> createState() => _AccountSectionWidgetState();
}

class _AccountSectionWidgetState extends State<AccountSectionWidget> {
  bool _isProcessingAuthAction = false;

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleForgotPassword(BuildContext context) async {
    if (widget.emailController.text.trim().isEmpty || !widget.emailController.text.contains('@')) {
      _showSnackBar(context, 'Please enter a valid email address to reset password.', isError: true);
      return;
    }
    if (!mounted) return;
    setState(() => _isProcessingAuthAction = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.sendPasswordResetEmail(widget.emailController.text.trim());
      _showSnackBar(context, 'Password reset email sent to ${widget.emailController.text.trim()}. Please check your inbox (and spam folder).');
    } on fb_auth.FirebaseAuthException catch (e) {
      String errorMessage = "Could not send reset email. Please try again.";
      if (e.code == 'user-not-found') {
        errorMessage = "No account found for that email address.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is not valid.";
      }
      _showSnackBar(context, errorMessage, isError: true);
    } catch (e) {
      _showSnackBar(context, "An unexpected error occurred: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessingAuthAction = false);
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    if (widget.appUser == null || widget.appUser!.isAnonymous) {
      _showSnackBar(context, "Cannot delete an anonymous account directly using this flow.", isError: true);
      return;
    }

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text(
            "This action is permanent and cannot be undone. All your associated data (prayer profile, prayer interactions, local favorites, reading progress, and settings) will be removed. Are you sure you want to proceed?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text("Delete My Account", style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;
    if (!mounted) return;

    setState(() => _isProcessingAuthAction = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.deleteCurrentUserAccount(context);
      _showSnackBar(context, "Account and associated data deleted successfully.");
    } on fb_auth.FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'requires-recent-login') {
        _showSnackBar(context, "Please re-authenticate to delete your account.", isError: true);
        
        final fb_auth.User? currentUser = fb_auth.FirebaseAuth.instance.currentUser;
        bool isEmailProvider = currentUser?.providerData.any((userInfo) => userInfo.providerId == fb_auth.EmailAuthProvider.PROVIDER_ID) ?? false;

        if (isEmailProvider && currentUser?.email != null) {
            final String? password = await _showReauthPasswordDialog(context, currentUser!.email!);
            if (password != null && password.isNotEmpty && mounted) {
                try {
                    await authService.reauthenticateUser(password);
                    await authService.deleteCurrentUserAccount(context);
                    _showSnackBar(context, "Account re-authenticated and deleted successfully.");
                } catch (reauthError) {
                   if(mounted) _showSnackBar(context, "Re-authentication failed or deletion still problematic: ${reauthError.toString()}", isError: true);
                }
            } else {
                 if(mounted) _showSnackBar(context, "Re-authentication cancelled.", isError: false);
            }
        } else {
             if(mounted) _showSnackBar(context, "Re-authentication required. Please sign out and sign back in to delete your account if you used a social provider.", isError: true);
        }
      } else {
        if(mounted) _showSnackBar(context, "Error deleting account: ${e.message ?? e.code}", isError: true);
      }
    } catch (e) {
      if(mounted) _showSnackBar(context, "An unexpected error occurred: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessingAuthAction = false);
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    showChangePasswordDialog(context: context, authService: authService);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final currentUser = Provider.of<AppUser?>(context); // Get AppUser for provider check

    bool isEmailPasswordUser = false;
    if (currentUser != null && !currentUser.isAnonymous) {
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      isEmailPasswordUser = fbUser?.providerData.any((userInfo) => userInfo.providerId == fb_auth.EmailAuthProvider.PROVIDER_ID) ?? false;
    }


    if (widget.appUser != null && !widget.appUser!.isAnonymous) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: widget.appUser!.photoURL != null && widget.appUser!.photoURL!.isNotEmpty
                  ? NetworkImage(widget.appUser!.photoURL!)
                  : null,
              child: widget.appUser!.photoURL == null || widget.appUser!.photoURL!.isEmpty
                  ? Icon(Icons.person_outline, size: 28, color: colorScheme.onPrimaryContainer)
                  : null,
              backgroundColor: colorScheme.primaryContainer,
            ),
            title: Text(widget.appUser!.displayName ?? widget.appUser!.email ?? "User Account", style: textTheme.titleMedium),
            subtitle: Text(widget.appUser!.email ?? "UID: ${widget.appUser!.uid}", style: textTheme.bodySmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text("Sign Out"),
                  onPressed: _isProcessingAuthAction ? null : widget.onSignOut,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.errorContainer),
                    foregroundColor: colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                 if (isEmailPasswordUser) ...[
                  TextButton.icon(
                    icon: Icon(Icons.password_rounded, color: colorScheme.primary),
                    label: Text("Change Password", style: TextStyle(color: colorScheme.primary)),
                    onPressed: _isProcessingAuthAction ? null : () => _showChangePasswordDialog(context),
                     style: TextButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                TextButton.icon(
                  icon: Icon(Icons.delete_forever_outlined, color: colorScheme.error),
                  label: Text("Delete My Account", style: TextStyle(color: colorScheme.error)),
                  onPressed: _isProcessingAuthAction ? null : () => _handleDeleteAccount(context),
                  style: TextButton.styleFrom(
                     padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_isProcessingAuthAction) {
      return const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: CircularProgressIndicator(),
      ));
    } else {
      // User is anonymous or null - show sign-in options
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.login_rounded),
              label: const Text("Sign in with Google"),
              onPressed: widget.onSignInWithGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("OR", style: textTheme.bodySmall),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 12),
            Form(
              key: widget.formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: widget.emailController,
                    decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter your email.';
                      if (!value.contains('@') || !value.contains('.')) return 'Please enter a valid email.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: widget.passwordController,
                    decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline)),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter your password.';
                      if (widget.isSignUpMode && value.length < 6) return 'Password must be at least 6 characters for new accounts.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isProcessingAuthAction ? null : widget.onSignInWithEmail,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                    child: Text(widget.isSignUpMode ? "Create Account" : "Sign In with Email"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _isProcessingAuthAction ? null : widget.onToggleSignUpMode,
                        child: Text(widget.isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Create one"),
                      ),
                      if (!widget.isSignUpMode)
                        TextButton(
                          onPressed: _isProcessingAuthAction ? null : () => _handleForgotPassword(context),
                          child: const Text("Forgot Password?"),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}