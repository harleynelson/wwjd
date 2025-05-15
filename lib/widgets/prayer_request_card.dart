// File: lib/widgets/prayer_request_card.dart
// Purpose: Widget to display a single prayer request on the prayer wall.
// It includes actions like "Pray for this" and "Report".

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting.
import 'package:provider/provider.dart'; // To access PrayerService.

import '../models/prayer_request_model.dart'; // Data model for a prayer request.
import '../services/prayer_service.dart'; // Service for prayer interactions.
// import '../models/app_user.dart'; // If needed to check if current user is the submitter (though prayers are anonymous)

class PrayerRequestCard extends StatefulWidget {
  final PrayerRequest prayerRequest;
  final String? currentUserId; // Firebase UID of the currently logged-in user.
                               // Used to check if they've already prayed/reported.

  const PrayerRequestCard({
    Key? key,
    required this.prayerRequest,
    this.currentUserId,
  }) : super(key: key);

  @override
  State<PrayerRequestCard> createState() => _PrayerRequestCardState();
}

class _PrayerRequestCardState extends State<PrayerRequestCard> {
  bool _isProcessingPrayAction = false; // Loading state for "Pray" button.
  bool _isProcessingReportAction = false; // Loading state for "Report" action.

  // Note: For a robust "_hasCurrentUserPrayed" or "_hasCurrentUserReported" state,
  // you would typically fetch interaction data from PrayerService when the card loads
  // or maintain a local cache of interacted prayer IDs.
  // The current implementation relies on the service to prevent duplicate actions,
  // and the UI might not immediately reflect "already prayed/reported" without such a check.
  // For simplicity here, we'll manage a session-based flag for "prayed".
  bool _sessionPrayed = false;


  // Shows a dialog for the user to confirm reporting a prayer and provide a reason.
  void _showReportDialog(BuildContext context) {
    final reportReasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Prayer'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Dialog content takes minimum space.
            children: [
              const Text('Are you sure you want to report this prayer? Please provide a brief reason if possible.'),
              const SizedBox(height: 16),
              TextFormField(
                controller: reportReasonController,
                decoration: const InputDecoration(
                  hintText: 'Reason for reporting (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                maxLength: 100, // Limit report reason length.
                // No validator, as reason is optional.
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
              if (widget.currentUserId == null) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You need to be logged in to report a prayer.')));
                Navigator.of(ctx).pop();
                return;
              }
              
              // No need to validate form if reason is optional.
              Navigator.of(ctx).pop(); // Close dialog first.
              
              if (mounted) setState(() => _isProcessingReportAction = true);
              
              final success = await Provider.of<PrayerService>(context, listen: false)
                  .reportPrayer(widget.prayerRequest.prayerId, reportReasonController.text.trim());
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Prayer reported for review.' : 'Failed to report prayer. You may have already reported it.')),
                );
                setState(() => _isProcessingReportAction = false);
                if (success) {
                  // Optionally, update UI to indicate it's been reported by this user (e.g., disable button).
                }
              }
            },
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );
  }

  // Handles the "Pray for this" action.
  Future<void> _togglePrayedAction() async {
    if (widget.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to pray for a request.')));
      return;
    }
    if (_sessionPrayed) { // Basic session check
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already prayed for this request in this session.')));
      return;
    }

    if (mounted) setState(() => _isProcessingPrayAction = true);

    final prayerService = Provider.of<PrayerService>(context, listen: false);
    final success = await prayerService.incrementPrayerCount(widget.prayerRequest.prayerId);

    if (mounted) {
      if (success) {
        // Optimistically update the UI. The stream from PrayerWallScreen will eventually
        // provide the source of truth from Firestore.
        setState(() {
          widget.prayerRequest.prayerCount++; // Increment local count for immediate feedback.
          _sessionPrayed = true; // Mark as prayed in this session.
        });
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your prayer!')));
      } else {
        // Failure might mean user already prayed (service prevents duplicates).
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not record your prayer. You might have already prayed for this.')));
        // If the backend confirms already prayed, you might want to set _sessionPrayed = true here too.
      }
      setState(() => _isProcessingPrayAction = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Format the timestamp for display (e.g., "May 10, 2024, 10:30 AM").
    final String formattedTimestamp = DateFormat.yMMMd().add_jm().format(widget.prayerRequest.timestamp.toDate());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Ensures content respects rounded corners.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prayer Text
            Text(
              widget.prayerRequest.prayerText,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.4, fontSize: 16),
              maxLines: 10, // Limit display lines, could add "Read more" if needed.
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Timestamp and Location
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submitted: $formattedTimestamp',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                      ),
                      if (widget.prayerRequest.locationApproximation != null &&
                          widget.prayerRequest.locationApproximation!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            'From: ${widget.prayerRequest.locationApproximation}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                          ),
                        ),
                    ],
                  ),
                ),
                // Report Button
                if (widget.currentUserId != null && widget.prayerRequest.submitterAnonymousId != widget.currentUserId) // Basic check to not report own, if IDs were comparable
                  IconButton(
                    icon: Icon(Icons.flag_outlined, color: Colors.grey.shade700, size: 22),
                    tooltip: 'Report Prayer',
                    onPressed: _isProcessingReportAction ? null : () => _showReportDialog(context),
                  ),
              ],
            ),
            const Divider(height: 24, thickness: 0.5),

            // Action Row: Pray Button
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the start
              children: [
                TextButton.icon(
                  icon: _isProcessingPrayAction
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : Icon(
                          _sessionPrayed ? Icons.favorite : Icons.favorite_border_outlined,
                          color: _sessionPrayed ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                  label: Text(
                    // Display "Prayed" if already prayed by this user in this session.
                    '${_sessionPrayed ? "Prayed" : "Pray for this"} (${widget.prayerRequest.prayerCount})',
                    style: TextStyle(
                       color: _sessionPrayed ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                       fontWeight: _sessionPrayed ? FontWeight.bold : FontWeight.normal,
                       fontSize: 14,
                    )
                  ),
                  onPressed: (_isProcessingPrayAction || _sessionPrayed) ? null : _togglePrayedAction,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                // Potentially add a share button or other actions here in the future.
              ],
            ),
             if (_isProcessingReportAction) // Show linear progress if reporting
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      ),
    );
  }
}
