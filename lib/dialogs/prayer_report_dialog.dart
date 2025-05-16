// File: lib/dialogs/prayer_report_dialog.dart
// Approximate line: 1
// New File (or adapt if you have a generic report dialog)
import 'package:flutter/material.dart';

/// Shows a dialog for the user to confirm reporting a prayer and provide a reason.
/// Calls [onSubmitReport] with the reason if the user submits.
Future<void> showPrayerReportDialog({
  required BuildContext context,
  required String prayerId, // ID of the prayer being reported
  required String? currentUserId, // To check if user can report
  required Future<bool> Function(String reason) onSubmitReport,
}) {
  final reportReasonController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Report Prayer'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Are you sure you want to report this prayer? Please provide a brief reason if possible.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: reportReasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for reporting (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              maxLength: 100,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        FilledButton(
          child: const Text('Submit Report'),
          onPressed: () async {
            if (currentUserId == null) {
              Navigator.of(ctx).pop(); // Close this dialog
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('You need to be logged in to report.')));
              return;
            }
            
            Navigator.of(ctx).pop(); // Close this dialog first
            // Call the provided callback to handle the actual submission
            // The callback is responsible for showing its own success/failure messages
            await onSubmitReport(reportReasonController.text.trim());
          },
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    ),
  );
}