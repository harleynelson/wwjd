// File: lib/widgets/prayer_request_card.dart
// Path: lib/widgets/prayer_request_card.dart
// Approximate line: 11 (Significant changes, simplifying the card)
// Note: This is a significant simplification. If the old PrayerRequestCard is needed elsewhere,
// consider creating a new widget e.g., `river_prayer_item.dart`

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting (though not used in simplified card)
import 'package:provider/provider.dart'; // To access PrayerService (for report)

import '../models/prayer_request_model.dart';
import '../services/prayer_service.dart';
// We will create a placeholder report dialog
import '../dialogs/prayer_report_dialog.dart';


// --- This is the NEW Simplified Prayer Item for the River ---
class RiverPrayerItem extends StatelessWidget {
  final PrayerRequest prayerRequest;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Animation<double>? animation; 

  const RiverPrayerItem({
    Key? key,
    required this.prayerRequest,
    required this.onTap,
    required this.onLongPress,
    this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Softer background, maybe a very subtle gradient or slightly more transparent
    final cardBackgroundColor = isDarkMode 
        ? Colors.white.withOpacity(0.08) 
        : theme.colorScheme.primaryContainer.withOpacity(0.25);
    
    final cardTextColor = isDarkMode
        ? Colors.grey.shade300
        : theme.colorScheme.onSurface.withOpacity(0.85);

    Widget item = Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 6.0), // Slightly adjusted margin
      decoration: BoxDecoration(
        // Subtle gradient for depth
        gradient: LinearGradient(
          colors: [
            cardBackgroundColor,
            cardBackgroundColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10), // Slightly more rounded
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Even softer shadow
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all( // Optional: very subtle border
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 0.5,
        )
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: theme.colorScheme.primary.withOpacity(0.15),
          highlightColor: theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          child: Padding( // Moved padding inside InkWell's child
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), // Adjusted padding
            child: Text(
              prayerRequest.prayerText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cardTextColor,
                height: 1.45, // Slightly more line spacing
                fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) * 0.95, // Slightly smaller text
              ),
              textAlign: TextAlign.center,
              maxLines: 3, 
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );

    if (animation != null) {
      return FadeTransition(
        opacity: Tween<double>(begin: 0.3, end: 1.0).animate( // Start more faded
          CurvedAnimation(parent: animation!, curve: Curves.easeInSine)
        ),
        child: ScaleTransition( // Add a subtle scale transition
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: animation!, curve: Curves.easeOutCubic)
          ),
          child: item,
        )
      );
    }
    return item;
  }
}

// --- Original PrayerRequestCard - Kept for reference or if needed elsewhere ---
// --- You might choose to delete this or move its contents if it's fully replaced ---
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
     // This now calls the separate dialog function
    showPrayerReportDialog(
      context: context,
      prayerId: widget.prayerRequest.prayerId,
      currentUserId: widget.currentUserId,
      onSubmitReport: (reason) async {
        if (widget.currentUserId == null) return false; // Should be handled by dialog too

        // The actual reporting logic is now inside the dialog or its callback
        // This state's role is just to manage its own loading indicator if any
        if (mounted) setState(() => _isProcessingReportAction = true);
        
        final success = await Provider.of<PrayerService>(context, listen: false)
            .reportPrayer(widget.prayerRequest.prayerId, reason);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(success ? 'Prayer reported for review.' : 'Failed to report prayer. You may have already reported it.')),
          );
          setState(() => _isProcessingReportAction = false);
          // UI update to show "reported" could happen here if success
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

    // THIS IS THE ORIGINAL CARD LAYOUT
    // It's kept here if you need it for 'My Submitted Prayers' or elsewhere.
    // For the new "River of Prayers", the `RiverPrayerItem` above is intended.
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