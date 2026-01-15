// File: lib/screens/submit_prayer_screen.dart
// Purpose: Screen for users to compose and submit their prayer requests.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // To access PrayerService and AppUser.
import 'package:shared_preferences/shared_preferences.dart'; // To save anonymous ID locally.

import '../../dialogs/premium_locked_dialog.dart';
import '../../services/prayer_service.dart'; // Service for prayer operations.
import '../../widgets/prayer_wall/prayer_form.dart'; // Reusable prayer input form.
import '../../dialogs/confirm_age_dialog.dart'; // Dialog for age confirmation.
import '../../dialogs/prayer_status_dialog.dart'; // Dialog for showing submission status.
import '../../models/app_user.dart'; // To check if AppUser is loaded.

class SubmitPrayerScreen extends StatefulWidget {
  static const routeName = '/submit-prayer'; // Route name for navigation.

  const SubmitPrayerScreen({Key? key}) : super(key: key);

  @override
  State<SubmitPrayerScreen> createState() => _SubmitPrayerScreenState();
}

class _SubmitPrayerScreenState extends State<SubmitPrayerScreen> {
  bool _isLoading = false; // Manages loading state during submission.

  // Handles the prayer submission process.
  Future<void> _handlePrayerSubmission(
      String prayerText, String? locationApproximation) async {

    final appUser = Provider.of<AppUser?>(context, listen: false);
    if (appUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not loaded. Please try again or re-login.')),
        );
      }
      return;
    }
    
    final bool? ageConfirmed = await showConfirmAgeDialog(context);
    if (ageConfirmed != true) { 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Age confirmation is required to submit a prayer.')),
        );
      }
      return; 
    }

    if (mounted) {
      setState(() {
        _isLoading = true; 
      });
    }

    final prayerService = Provider.of<PrayerService>(context, listen: false);

    try {
      final submissionResult = await prayerService.submitPrayer(
        context: context, 
        prayerText: prayerText,
        isAdultConfirmed: true, 
        locationApproximation: locationApproximation,
      );

      if (mounted) { 
        if (submissionResult != null && submissionResult['error'] == null) {
          final prayerId = submissionResult['prayerId'];
          final submitterAnonymousId = submissionResult['submitterAnonymousId'];

          if (submitterAnonymousId != null && submitterAnonymousId.isNotEmpty) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('submitterAnonymousId', submitterAnonymousId);
            print("Saved submitterAnonymousId to SharedPreferences: $submitterAnonymousId");
          }

          await showPrayerStatusDialog( 
            context,
            success: true,
            prayerId: prayerId,
            submitterAnonymousId: submitterAnonymousId,
            message: 'Your prayer has been sent for review. You can use the Anonymous ID to track its interactions once approved.',
          );
          
          if (mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop(true); 
          }

        } else {
          // --- UPDATED ERROR HANDLING ---
          final errorMessage = submissionResult?['error'] ?? 'An unknown error occurred.';
          
          // Check if the error is related to the weekly limit (text matches PrayerService logic)
          if (errorMessage.contains('limit') || errorMessage.contains('submission limit')) {
             await PremiumLockedDialog.show(context, featureName: "Unlimited Prayers");
          } else {
             // Show standard error for other issues (network, database, etc.)
             showPrayerStatusDialog(
              context,
              success: false,
              message: errorMessage,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showPrayerStatusDialog(
          context,
          success: false,
          message: 'An unexpected error occurred: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit a Prayer'),
        elevation: 1, // Subtle shadow for the AppBar.
      ),
      body: SingleChildScrollView( // Allows content to scroll if it overflows.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: PrayerForm(
            onSubmit: _handlePrayerSubmission,
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }
}
