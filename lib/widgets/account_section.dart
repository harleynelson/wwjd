// lib/widgets/account_section.dart
import 'package:flutter/material.dart';
import 'package:wwjd_app/models/app_user.dart'; // Your AppUser model

class AccountSection extends StatelessWidget {
  final AppUser? appUser;
  final bool isAuthActionLoading;
  final VoidCallback onSignInWithGoogle;
  final VoidCallback onSignInWithEmail;
  final VoidCallback onToggleSignUpMode;
  final VoidCallback onSignOut;
  final bool isSignUpMode;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const AccountSection({
    super.key, // Changed from Key? key to super.key for modern Dart
    required this.appUser,
    required this.isAuthActionLoading,
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
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (appUser != null && !appUser!.isAnonymous) {
      // User is signed in and not anonymous
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: appUser!.photoURL != null && appUser!.photoURL!.isNotEmpty
                  ? NetworkImage(appUser!.photoURL!)
                  : null,
              child: appUser!.photoURL == null || appUser!.photoURL!.isEmpty
                  ? Icon(Icons.person_outline, size: 28, color: colorScheme.onPrimaryContainer)
                  : null,
              backgroundColor: colorScheme.primaryContainer,
            ),
            title: Text(appUser!.displayName ?? appUser!.email ?? "User Account", style: textTheme.titleMedium),
            subtitle: Text(appUser!.email ?? "UID: ${appUser!.uid}", style: textTheme.bodySmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded),
                label: const Text("Sign Out"),
                onPressed: isAuthActionLoading ? null : onSignOut,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.error),
                  foregroundColor: colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (isAuthActionLoading) {
      // Loading indicator
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
              icon: const Icon(Icons.login_rounded), // Placeholder, consider a Google specific icon
              label: const Text("Sign in with Google"),
              onPressed: onSignInWithGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade700, // Example color
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
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
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
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline)),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter your password.';
                      if (value.length < 6) return 'Password must be at least 6 characters.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onSignInWithEmail,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                    child: Text(isSignUpMode ? "Create Account" : "Sign In with Email"),
                  ),
                  TextButton(
                    onPressed: onToggleSignUpMode,
                    child: Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Create one"),
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