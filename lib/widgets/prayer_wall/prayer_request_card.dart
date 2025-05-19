// File: lib/widgets/prayer_wall/prayer_request_card.dart
// Path: lib/widgets/prayer_wall/prayer_request_card.dart
// Updated: Removed RiverPrayerItem widget. This file now only contains PrayerRequestCard.

import 'package:flutter/material.dart';
// import 'dart:math'; // No longer needed here if RiverPrayerItem is gone
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/prayer_request_model.dart';
import '../../services/prayer_service.dart';
import '../../dialogs/prayer_report_dialog.dart';

// RiverPrayerItem widget has been moved to its own file:
// lib/widgets/prayer_wall/river_prayer_item.dart


// --- Original PrayerRequestCard - Stays in this file ---
class PrayerRequestCard extends StatefulWidget {
  final PrayerRequest prayerRequest;
  final String? currentUserId;

  const PrayerRequestCard({
    Key? key,
    required this.prayerRequest,
    this.currentUserId,
  }) : super(key: key);

  @override
  State<PrayerRequestCard> createState() => _PrayerRequestCardState();
}

class _PrayerRequestCardState extends State<PrayerRequestCard> {
  bool _isProcessingPrayAction = false;
  bool _isProcessingReportAction = false;
  bool _sessionPrayed = false;


  void _showReportDialog(BuildContext context) {
    showPrayerReportDialog(
      context: context,
      prayerId: widget.prayerRequest.prayerId,
      currentUserId: widget.currentUserId,
      onSubmitReport: (reason) async {
        if (widget.currentUserId == null) return false;

        if (mounted) setState(() => _isProcessingReportAction = true);

        final success = await Provider.of<PrayerService>(context, listen: false)
            .reportPrayer(widget.prayerRequest.prayerId, reason);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(success ? 'Prayer reported for review.' : 'Failed to report prayer. You may have already reported it.')),
          );
          setState(() => _isProcessingReportAction = false);
        }
        return success;
      }
    );
  }

  Future<void> _togglePrayedAction() async {
    if (widget.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to pray for a request.')));
      return;
    }
    if (_sessionPrayed) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already prayed for this request in this session.')));
      return;
    }

    if (mounted) setState(() => _isProcessingPrayAction = true);

    final prayerService = Provider.of<PrayerService>(context, listen: false);
    final success = await prayerService.incrementPrayerCount(widget.prayerRequest.prayerId);

    if (mounted) {
      if (success) {
        setState(() {
          widget.prayerRequest.prayerCount++;
          _sessionPrayed = true;
        });
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your prayer!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not record your prayer. You might have already prayed for this.')));
      }
      setState(() => _isProcessingPrayAction = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String formattedTimestamp = DateFormat.yMMMd().add_jm().format(widget.prayerRequest.timestamp.toDate());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.prayerRequest.prayerText,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.4, fontSize: 16),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
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
                if (widget.currentUserId != null && widget.prayerRequest.submitterAnonymousId != widget.currentUserId)
                  IconButton(
                    icon: Icon(Icons.flag_outlined, color: Colors.grey.shade700, size: 22),
                    tooltip: 'Report Prayer',
                    onPressed: _isProcessingReportAction ? null : () => _showReportDialog(context),
                  ),
              ],
            ),
            const Divider(height: 24, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
              ],
            ),
             if (_isProcessingReportAction)
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