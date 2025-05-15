// File: lib/screens/submit_prayer_screen.dart
// Purpose: Screen for users to compose and submit their prayer requests.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // To access PrayerService and AppUser.
import 'package:shared_preferences/shared_preferences.dart'; // To save anonymous ID locally.

import '../services/prayer_service.dart'; // Service for prayer operations.
import '../widgets/prayer_form.dart'; // Reusable prayer input form.
import '../dialogs/confirm_age_dialog.dart'; // Dialog for age confirmation.
import '../dialogs/prayer_status_dialog.dart'; // Dialog for showing submission status.
import '../models/app_user.dart'; // To check if AppUser is loaded.

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
    // bool submissionWasSuccessful = false; // Not strictly needed if we pop with result

    try {
      final submissionResult = await prayerService.submitPrayer(
        context: context, 
        prayerText: prayerText,
        isAdultConfirmed: true, 
        locationApproximation: locationApproximation,
      );

      if (mounted) { 
        if (submissionResult != null && submissionResult['error'] == null) {
          // submissionWasSuccessful = true; 
          final prayerId = submissionResult['prayerId'];
          final submitterAnonymousId = submissionResult['submitterAnonymousId'];

          if (submitterAnonymousId != null && submitterAnonymousId.isNotEmpty) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('submitterAnonymousId', submitterAnonymousId);
            print("Saved submitterAnonymousId to SharedPreferences: $submitterAnonymousId");
          }

          // Clear the form fields (assuming _prayerTextController is part of PrayerForm state,
          // this needs to be handled by resetting the PrayerForm's controllers or its key)
          // For simplicity, if PrayerForm's controllers are managed within SubmitPrayerScreen, clear them here.
          // If PrayerForm manages its own controllers, you'd call a clear method on PrayerForm's state.
          // Assuming _prayerTextController is available here (if PrayerForm was part of this state):
          // _prayerTextController.clear(); 
          // _selectedLocation = null; // If location is also managed here

          // For now, we'll rely on popping the screen, which naturally "clears" it for the next visit.
          // A more robust clear would involve resetting the PrayerForm's GlobalKey if you have one.


          // Show the dialog with details and await its dismissal
          await showPrayerStatusDialog( 
            context,
            success: true,
            prayerId: prayerId,
            submitterAnonymousId: submitterAnonymousId,
            message: 'Your prayer has been sent for review. You can use the Anonymous ID to track its interactions once approved.',
          );
          // After dialog is dismissed, pop SubmitPrayerScreen with true for success
          if (mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop(true); 
          }

        } else {
          showPrayerStatusDialog(
            context,
            success: false,
            message: submissionResult?['error'] ?? 'An unknown error occurred during submission.',
          );
          // Optionally pop with false if submission failed and you want the caller to know
          // if (mounted && Navigator.canPop(context)) {
          //   Navigator.of(context).pop(false);
          // }
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
