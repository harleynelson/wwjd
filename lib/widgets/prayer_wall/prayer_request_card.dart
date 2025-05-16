// File: lib/widgets/prayer_wall/prayer_request_card.dart
// Path: lib/widgets/prayer_wall/prayer_request_card.dart
// Entire RiverPrayerItem widget updated for new look and shorter height.

import 'package:flutter/material.dart';
import 'dart:math'; // For random gradient alignment in RiverPrayerItem

// Provider and Intl are for the original PrayerRequestCard, not directly used in RiverPrayerItem
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


import '../../models/prayer_request_model.dart';
import '../../services/prayer_service.dart'; // Used by original PrayerRequestCard
import '../../dialogs/prayer_report_dialog.dart'; // Used by original PrayerRequestCard


// --- Updated RiverPrayerItem ---
class RiverPrayerItem extends StatelessWidget {
  final PrayerRequest prayerRequest;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Animation<double>? animation;

  RiverPrayerItem({
    Key? key,
    required this.prayerRequest,
    required this.onTap,
    required this.onLongPress,
    this.animation,
  }) : super(key: key);

  // Helper for random gradient alignment
  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Assuming PrayerWallScreen now forces a dark background,
    // these colors are chosen for good visibility on a dark theme.

    final List<Color> cardGradientColors = [
      Colors.lightBlue.shade300.withOpacity(0.15),
      Colors.purple.shade300.withOpacity(0.20),
      Colors.teal.shade300.withOpacity(0.15),
    ];

    final cardTextColor = Colors.white.withOpacity(0.9);

    final prayerTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: cardTextColor,
      height: 1.35, // Slightly reduced line height for shorter cards
      fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) * 0.92, // Slightly smaller font
      shadows: [
        Shadow(
          blurRadius: 8.0,
          color: Colors.cyanAccent.withOpacity(0.5),
          offset: const Offset(0, 0),
        ),
        Shadow(
          blurRadius: 4.0,
          color: Colors.white.withOpacity(0.3),
          offset: const Offset(0, 0),
        ),
      ],
    );

    Widget item = Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0), // Reduced margins
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardGradientColors,
          begin: Alignment(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1),
          end: Alignment(_random.nextDouble() * 2 - 1, _random.nextDouble() * 2 - 1),
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(14), // Softer rounding
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.30),
            blurRadius: 10,
            spreadRadius: 0.5,
            offset: const Offset(0, 0),
          ),
           BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 2,
            offset: const Offset(1, 1),
          )
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.20),
          width: 0.6,
        )
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: Colors.lightBlue.withOpacity(0.3),
          highlightColor: Colors.lightBlue.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // Reduced vertical padding
            child: Center(
              child: Text(
                prayerRequest.prayerText,
                style: prayerTextStyle,
                textAlign: TextAlign.center,
                maxLines: 3, // Reduced maxLines to make cards shorter
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );

    if (animation != null) {
      return FadeTransition(
        opacity: Tween<double>(begin: 0.4, end: 1.0).animate(
          CurvedAnimation(parent: animation!, curve: Curves.easeInSine)
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: animation!, curve: Curves.easeOutExpo)
          ),
          child: item,
        )
      );
    }
    return item;
  }
}


// --- Original PrayerRequestCard - Kept for reference or if needed elsewhere ---
// (No changes to this part for the current request)
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