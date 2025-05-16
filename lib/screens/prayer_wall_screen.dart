// File: lib/screens/prayer_wall_screen.dart
// Path: lib/screens/prayer_wall_screen.dart
// Approximate line: 1 (Complete rewrite of the screen)
import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/prayer_request_model.dart';
import '../services/prayer_service.dart';
import '../widgets/prayer_request_card.dart'; // Now contains RiverPrayerItem
import '../widgets/prayer_wall/well_of_hope_widget.dart';
import '../widgets/prayer_wall/animated_prayer_mote.dart';
import './submit_prayer_screen.dart';
import '../dialogs/prayer_report_dialog.dart'; // For the report action

// Helper class for managing prayer items in the river
class RiverPrayerVisual {
  final PrayerRequest prayer;
  final GlobalKey itemKey; // To get position for animation start
  final AnimationController? controller; // For list animations if using AnimatedList

  RiverPrayerVisual({required this.prayer, AnimationController? animController})
      : itemKey = GlobalKey(),
        controller = animController;
}

// Helper for the mote animation
class PrayerMoteAnimation {
  final String prayerId; // To identify which prayer this mote represents
  final AnimationController controller;
  final Animation<double> progress;
  final GlobalKey startKey; // Key of the RiverPrayerItem
  final GlobalKey endKey;   // Key of the WellOfHopeWidget
  Offset? currentPosition; // For drawing in Overlay

  PrayerMoteAnimation({
    required this.prayerId,
    required this.controller,
    required this.startKey,
    required this.endKey,
  }) : progress = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);
}


class PrayerWallScreen extends StatefulWidget {
  static const routeName = '/prayer-wall';

  const PrayerWallScreen({super.key});

  @override
  State<PrayerWallScreen> createState() => _PrayerWallScreenState();
}

class _PrayerWallScreenState extends State<PrayerWallScreen> with TickerProviderStateMixin {
  final GlobalKey _wellOfHopeKey = GlobalKey();
  List<RiverPrayerVisual> _riverPrayers = [];
  StreamSubscription? _prayerStreamSubscription;
  final int _maxRiverPrayers = 7; // Max prayers visible in the river at once
  final Random _random = Random();

  // For managing the "transporting" prayer mote animation
  PrayerMoteAnimation? _activeMoteAnimation;
  OverlayEntry? _moteOverlayEntry;

  @override
  void initState() {
    super.initState();
    final prayerService = Provider.of<PrayerService>(context, listen: false);
    _prayerStreamSubscription = prayerService.getApprovedPrayers(limit: 20).listen(
      (prayers) {
        if (!mounted) return;
        _updateRiverPrayers(prayers);
      },
      onError: (error) {
        print("PrayerWallScreen Stream Error: $error");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading prayers: $error')),
          );
        }
      },
    );
  }

  void _updateRiverPrayers(List<PrayerRequest> newPrayers) {
    // Basic strategy: If river is not full, add new prayers.
    // If full, replace oldest ones or randomly. More sophisticated logic can be added for "flow".
    // This version will simply try to keep a fresh set.
    
    List<PrayerRequest> prayersToDisplay = List.from(newPrayers);
    prayersToDisplay.shuffle(_random); // Randomize initially

    // If we are animating a mote for a prayer, don't remove that prayer from source list yet
    Set<String> animatingPrayerIds = {};
    if (_activeMoteAnimation != null) {
      animatingPrayerIds.add(_activeMoteAnimation!.prayerId);
    }

    // Filter out prayers that are currently being animated away
    final currentRiverPrayerIds = _riverPrayers.map((rp) => rp.prayer.prayerId).toSet();
    final availableNewPrayers = prayersToDisplay
        .where((p) => !currentRiverPrayerIds.contains(p.prayerId) && !animatingPrayerIds.contains(p.prayerId) )
        .toList();


    List<RiverPrayerVisual> updatedRiver = List.from(_riverPrayers.where((rp) => !animatingPrayerIds.contains(rp.prayer.prayerId)));

    // Remove some old ones if list is too full to make space for new ones
    while(updatedRiver.length >= _maxRiverPrayers && availableNewPrayers.isNotEmpty) {
        if (updatedRiver.isNotEmpty) updatedRiver.removeAt(_random.nextInt(updatedRiver.length)); // Remove a random old one
    }

    // Add new ones until max capacity
    int canAdd = _maxRiverPrayers - updatedRiver.length;
    for(int i=0; i < min(canAdd, availableNewPrayers.length); i++) {
        updatedRiver.add(RiverPrayerVisual(prayer: availableNewPrayers[i]));
    }
    
    updatedRiver.shuffle(_random); // Shuffle the display order

    setState(() {
      _riverPrayers = updatedRiver.take(_maxRiverPrayers).toList();
    });
  }


  void _handlePrayForRequest(RiverPrayerVisual riverPrayerVisual) {
    final prayerRequest = riverPrayerVisual.prayer;
    final prayerService = Provider.of<PrayerService>(context, listen: false);
    final currentUser = Provider.of<User?>(context, listen: false);

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to pray for requests.')));
      return;
    }

    // Immediately remove from visual list or mark as "being prayed for"
    // For simplicity, we'll trigger animation then remove.
    
    final moteController = AnimationController(
      duration: const Duration(milliseconds: 1200), // Slower for visual travel
      vsync: this,
    );

    _activeMoteAnimation = PrayerMoteAnimation(
      prayerId: prayerRequest.prayerId,
      controller: moteController,
      startKey: riverPrayerVisual.itemKey,
      endKey: _wellOfHopeKey,
    );
    
    // Create OverlayEntry
    _moteOverlayEntry = OverlayEntry(builder: (context) {
        final startRenderBox = riverPrayerVisual.itemKey.currentContext?.findRenderObject() as RenderBox?;
        final endRenderBox = _wellOfHopeKey.currentContext?.findRenderObject() as RenderBox?;

        if (startRenderBox == null || !startRenderBox.hasSize || endRenderBox == null || !endRenderBox.hasSize) {
            return const SizedBox.shrink(); // Keys not ready
        }
        final startOffset = startRenderBox.localToGlobal(Offset.zero);
        final endOffset = endRenderBox.localToGlobal(Offset(endRenderBox.size.width / 2, endRenderBox.size.height / 2));
        
        return AnimatedPrayerMote(
            progress: _activeMoteAnimation!.progress,
            startPosition: startOffset + Offset(startRenderBox.size.width /2, startRenderBox.size.height /2), // Center of card
            endPosition: endOffset,
            prayerText: prayerRequest.prayerText,
        );
    });

    Overlay.of(context).insert(_moteOverlayEntry!);
    
    // Animate the mote
    moteController.forward().then((_) async {
      // Animation complete
      _moteOverlayEntry?.remove();
      _moteOverlayEntry = null;
      _activeMoteAnimation = null;
      moteController.dispose();

      // Trigger absorption effect on the Well
      (_wellOfHopeKey.currentState as dynamic)
          ?.triggerAbsorptionEffect(
          // We need the global position of where the mote "landed"
          // This might need refinement based on AnimatedPrayerMote's final position logic
          (_wellOfHopeKey.currentContext?.findRenderObject() as RenderBox)
              .localToGlobal(Offset(
                (_wellOfHopeKey.currentContext?.size?.width ?? 0) / 2,
                (_wellOfHopeKey.currentContext?.size?.height ?? 0) / 2,
              ))
      );

      // Increment prayer count in Firestore
      final success = await prayerService.incrementPrayerCount(prayerRequest.prayerId);
      if (success) {
        // Optional: Snack bar, but the visual is the main feedback
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Your prayer has been sent to the Well!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not record prayer. Already prayed?")));
      }
      // Remove prayer from local river list after animation and Firestore update
      setState(() {
        _riverPrayers.removeWhere((p) => p.prayer.prayerId == prayerRequest.prayerId);
        // Potentially fetch a new prayer to keep the river flowing
         _prayerStreamSubscription?.cancel(); // Cancel existing before re-subscribing
         _prayerStreamSubscription = prayerService.getApprovedPrayers(limit: 20).listen(
          (prayers) {
            if (!mounted) return;
            _updateRiverPrayers(prayers);
          });
      });
    });
  }

  void _handleReportPrayer(PrayerRequest prayerRequest) {
    final prayerService = Provider.of<PrayerService>(context, listen: false);
    final currentUser = Provider.of<User?>(context, listen: false);

    showPrayerReportDialog(
      context: context,
      prayerId: prayerRequest.prayerId,
      currentUserId: currentUser?.uid,
      onSubmitReport: (reason) async {
         if (currentUser == null) return false;
         bool success = await prayerService.reportPrayer(prayerRequest.prayerId, reason);
         if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(success ? 'Prayer reported.' : 'Failed to report.')));
            if(success){
                 setState(() {
                    _riverPrayers.removeWhere((p) => p.prayer.prayerId == prayerRequest.prayerId);
                 });
            }
         }
         return success;
      }
    );
  }

  @override
  void dispose() {
    _prayerStreamSubscription?.cancel();
    _activeMoteAnimation?.controller.dispose();
    _moteOverlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User?>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Wall of Hope'),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Submit a Prayer',
            onPressed: () {
              if (currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in to submit a prayer.')));
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubmitPrayerScreen()),
              ).then((_) {
                // Optional: refresh or show message after submission screen closes
              });
            },
          ),
        ],
      ),
      body: Stack( // Use Stack to layer mote animations over everything
        children: [
          Column(
            children: [
              // Top Half: Well of Collective Hope
              Expanded(
                flex: 2, // Adjust flex factor as needed for desired height ratio
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer.withOpacity(0.3),
                        theme.colorScheme.background,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.9]
                    )
                  ),
                  child: WellOfHopeWidget(wellKey: _wellOfHopeKey),
                ),
              ),
              // Bottom Half: River of Prayers
              Expanded(
                flex: 3, // Adjust flex factor
                child: Container(
                  color: theme.colorScheme.background, // Or a subtle gradient
                  child: _riverPrayers.isEmpty
                      ? Center(
                          child: _prayerStreamSubscription == null || Provider.of<PrayerService>(context, listen:false) == null // crude check if initial load failed
                              ? const Text("Loading prayers...")
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.water_drop_outlined, size: 48, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5)),
                                    const SizedBox(height: 16),
                                    Text(
                                      "The river is quiet for now.\nNew prayers will appear here.",
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                                    ),
                                  ],
                                ),
                        )
                      : GridView.builder( // Or ListView, or a custom layout
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 250.0, // Max width of a prayer item
                              childAspectRatio: 2.5 / 1, // Adjust for text content height
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                          ),
                          itemCount: _riverPrayers.length,
                          itemBuilder: (context, index) {
                            final riverPrayer = _riverPrayers[index];
                            return RiverPrayerItem(
                              key: riverPrayer.itemKey, // Assign key here
                              prayerRequest: riverPrayer.prayer,
                              onTap: () => _handlePrayForRequest(riverPrayer),
                              onLongPress: () => _handleReportPrayer(riverPrayer.prayer),
                            );
                          },
                        ),
                ),
              ),
              // Instructional Text
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Tap a prayer to send your support. Tap and hold to report.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          // The Overlay will handle the AnimatedPrayerMote through _moteOverlayEntry
        ],
      ),
    );
  }
}