// File: lib/screens/prayer_wall/prayer_wall_screen.dart
// Path: lib/screens/prayer_wall/prayer_wall_screen.dart
// Entire file updated for layout changes (dark background, FAB, padding).

import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/prayer_request_model.dart';
import '../../services/prayer_service.dart';
import '../../widgets/prayer_wall/prayer_request_card.dart'; // Contains RiverPrayerItem
import '../../widgets/prayer_wall/well_of_hope_widget.dart';
import '../../widgets/prayer_wall/animated_prayer_mote.dart';
import 'submit_prayer_screen.dart';
import '../../dialogs/prayer_report_dialog.dart';

// Helper class for managing prayer items in the river
class RiverPrayerVisual {
  final PrayerRequest prayer;
  final GlobalKey itemKey;

  RiverPrayerVisual({required this.prayer})
      : itemKey = GlobalKey();
}

// Helper for the mote animation
class PrayerMoteAnimation {
  final String prayerId;
  final AnimationController controller;
  final Animation<double> progress;
  final GlobalKey startKey;
  final GlobalKey endKey;
  Offset? currentPosition;

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
  final GlobalKey _wellOfHopeWidgetStateKey = GlobalKey();
  final GlobalKey _wellOfHopeKey = GlobalKey();


  List<RiverPrayerVisual> _riverPrayers = [];
  StreamSubscription? _prayerStreamSubscription;
  final int _maxRiverPrayersToShowAtOnce = 7;
  final Random _random = Random();

  late PageController _pageController;
  Timer? _autoCycleTimer;
  int _currentPage = 0;
  bool _isUserInteractingWithPage = false;
  bool _isPageAnimatingProgrammatically = false;

  PrayerMoteAnimation? _activeMoteAnimation;
  OverlayEntry? _moteOverlayEntry;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.75,
      initialPage: _currentPage,
    );
    _pageController.addListener(_handlePageScroll);

    final prayerService = Provider.of<PrayerService>(context, listen: false);
    _prayerStreamSubscription = prayerService.getApprovedPrayers(limit: 20).listen(
      (prayers) {
        if (!mounted) return;
        _updateRiverPrayersList(prayers);
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

  void _handlePageScroll() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page;
    if (page == null) return;

    if (page == page.roundToDouble()) {
      final settledPage = page.round();
      if (_currentPage != settledPage) {
        _currentPage = settledPage;
      }
      if (_isUserInteractingWithPage || _isPageAnimatingProgrammatically) {
        _isUserInteractingWithPage = false;
        _isPageAnimatingProgrammatically = false;
        _resetAutoCycleTimer();
      }
    } else {
      if (!_isPageAnimatingProgrammatically) {
         _isUserInteractingWithPage = true;
         _autoCycleTimer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _prayerStreamSubscription?.cancel();
    _activeMoteAnimation?.controller.dispose();
    _moteOverlayEntry?.remove();
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    _autoCycleTimer?.cancel();
    super.dispose();
  }

  void _startAutoCycleTimer() {
    _autoCycleTimer?.cancel();
    if (!mounted || _riverPrayers.length <= 1) return;

    _autoCycleTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted || _isUserInteractingWithPage || !_pageController.hasClients || (_pageController.page != _pageController.page?.roundToDouble()) ) return;

      _isPageAnimatingProgrammatically = true;
      int nextPage = _currentPage + 1;
      if (nextPage >= _riverPrayers.length) {
        nextPage = 0;
      }

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutSine,
      );
      // _handlePageScroll will update _currentPage and reset timer upon completion
    });
  }

  void _resetAutoCycleTimer() {
    _autoCycleTimer?.cancel();
    if(mounted && _riverPrayers.length > 1) {
        _startAutoCycleTimer();
    }
  }

  void _updateRiverPrayersList(List<PrayerRequest> newPrayersFromStream) {
    if (!mounted) return;

    List<PrayerRequest> potentialPrayers = List.from(newPrayersFromStream);
    potentialPrayers.shuffle(_random);

    Set<String> animatingPrayerIds = {};
    if (_activeMoteAnimation != null) {
      animatingPrayerIds.add(_activeMoteAnimation!.prayerId);
    }

    final filteredPotentialPrayers = potentialPrayers
        .where((p) => !animatingPrayerIds.contains(p.prayerId))
        .toList();

    List<RiverPrayerVisual> newVisuals = filteredPotentialPrayers
        .take(_maxRiverPrayersToShowAtOnce)
        .map((p) => RiverPrayerVisual(prayer: p))
        .toList();

    bool listActuallyChanged = false;
    if (_riverPrayers.length != newVisuals.length) {
        listActuallyChanged = true;
    } else {
        for(int i = 0; i < _riverPrayers.length; i++) {
            if(_riverPrayers[i].prayer.prayerId != newVisuals[i].prayer.prayerId) {
                listActuallyChanged = true;
                break;
            }
        }
    }

    if (listActuallyChanged || (_riverPrayers.isEmpty && newVisuals.isNotEmpty) ) {
         setState(() {
            _riverPrayers = newVisuals;
            if (_currentPage >= _riverPrayers.length) {
                _currentPage = _riverPrayers.isNotEmpty ? max(0, _riverPrayers.length - 1) : 0;
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if(mounted && _pageController.hasClients) {
                int targetPage = _currentPage;
                if (_riverPrayers.isEmpty) {
                    targetPage = 0;
                } else if (targetPage >= _riverPrayers.length) {
                    targetPage = max(0, _riverPrayers.length - 1);
                }
                
                if (_pageController.page?.round() != targetPage) {
                    _pageController.jumpToPage(targetPage);
                }
              }
            });
        });
    }
    _resetAutoCycleTimer();
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

    _autoCycleTimer?.cancel();
    _isUserInteractingWithPage = true;

    setState(() {
       _activeMoteAnimation = PrayerMoteAnimation(
        prayerId: prayerRequest.prayerId,
        controller: AnimationController(
            duration: const Duration(milliseconds: 1200),
            vsync: this,
        ),
        startKey: riverPrayerVisual.itemKey,
        endKey: _wellOfHopeKey,
      );
    });

    _moteOverlayEntry = OverlayEntry(builder: (context) {
        final startRenderBox = riverPrayerVisual.itemKey.currentContext?.findRenderObject() as RenderBox?;
        final endRenderBox = _wellOfHopeKey.currentContext?.findRenderObject() as RenderBox?;

        if (startRenderBox == null || !startRenderBox.hasSize || endRenderBox == null || !endRenderBox.hasSize) {
            _activeMoteAnimation?.controller.dispose();
            _activeMoteAnimation = null;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _moteOverlayEntry?.remove();
              _moteOverlayEntry = null;
            });
            return const SizedBox.shrink();
        }
        final startOffset = startRenderBox.localToGlobal(Offset.zero);
        final endOffset = endRenderBox.localToGlobal(Offset(endRenderBox.size.width / 2, endRenderBox.size.height / 2));

        return AnimatedPrayerMote(
            progress: _activeMoteAnimation!.progress,
            startPosition: startOffset + Offset(startRenderBox.size.width /2, startRenderBox.size.height /2),
            endPosition: endOffset,
            prayerText: prayerRequest.prayerText,
        );
    });

    Overlay.of(context).insert(_moteOverlayEntry!);

    _activeMoteAnimation!.controller.forward().then((_) async {
      _moteOverlayEntry?.remove();
      _moteOverlayEntry = null;
      _activeMoteAnimation?.controller.dispose();
      _activeMoteAnimation = null;

      final wellState = _wellOfHopeWidgetStateKey.currentState;
      if (wellState != null) {
          final RenderBox? wellRenderBox = _wellOfHopeKey.currentContext?.findRenderObject() as RenderBox?;
          if (wellRenderBox != null && wellRenderBox.hasSize) {
             final wellCenterGlobal = wellRenderBox.localToGlobal(Offset(wellRenderBox.size.width /2, wellRenderBox.size.height /2));
             (wellState as dynamic).triggerAbsorptionEffect(wellCenterGlobal);
          }
      }
      await prayerService.incrementPrayerCount(prayerRequest.prayerId);

      if(mounted){
        int removedIndex = _riverPrayers.indexWhere((p) => p.prayer.prayerId == prayerRequest.prayerId);
        if (removedIndex != -1) {
            _riverPrayers.removeAt(removedIndex);
            if (_currentPage >= removedIndex && _currentPage > 0) {
                _currentPage = max(0, _currentPage - 1);
            }
             if (_riverPrayers.isEmpty) _currentPage = 0;
             else if (_currentPage >= _riverPrayers.length) _currentPage = max(0, _riverPrayers.length -1);

            setState(() { /* _riverPrayers already modified */ });

            WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _pageController.hasClients) {
                    int targetPage = _currentPage;
                    if (_riverPrayers.isEmpty) targetPage = 0;
                    else if (targetPage >= _riverPrayers.length) targetPage = max(0, _riverPrayers.length - 1);
                    
                    // Only jump if necessary and page is valid
                    if(_riverPrayers.isNotEmpty && _pageController.page?.round() != targetPage) {
                        _pageController.jumpToPage(targetPage);
                    } else if (_riverPrayers.isEmpty && _pageController.page?.round() != 0) {
                         // No items to jump to, but ensure controller is at 0 if it wasn't
                        // _pageController.jumpToPage(0); // PageView builder will handle empty
                    }
                }
            });
        }
        _isUserInteractingWithPage = false;
        _resetAutoCycleTimer();
      }
    }).catchError((e) {
        print("Error during mote animation or post-animation: $e");
        if (mounted) {
            _moteOverlayEntry?.remove();
            _moteOverlayEntry = null;
            _activeMoteAnimation?.controller.dispose();
            _activeMoteAnimation = null;
            _isUserInteractingWithPage = false;
            _resetAutoCycleTimer();
        }
    });
  }

  void _handleReportPrayer(PrayerRequest prayerRequest) {
    final prayerService = Provider.of<PrayerService>(context, listen: false);
    final currentUser = Provider.of<User?>(context, listen: false);

    _autoCycleTimer?.cancel();
    _isUserInteractingWithPage = true;

    showPrayerReportDialog(
      context: context,
      prayerId: prayerRequest.prayerId,
      currentUserId: currentUser?.uid,
      onSubmitReport: (reason) async {
         if (currentUser == null) {
            _isUserInteractingWithPage = false;
            _resetAutoCycleTimer();
            return false;
         }
         bool success = await prayerService.reportPrayer(prayerRequest.prayerId, reason);
         if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(success ? 'Prayer reported.' : 'Failed to report.')));
            if(success){
                 int removedIndex = _riverPrayers.indexWhere((p) => p.prayer.prayerId == prayerRequest.prayerId);
                  if (removedIndex != -1) {
                      _riverPrayers.removeAt(removedIndex);
                      if (_currentPage >= removedIndex && _currentPage > 0) {
                          _currentPage = max(0, _currentPage - 1);
                      }
                      if (_riverPrayers.isEmpty) _currentPage = 0;
                      else if (_currentPage >= _riverPrayers.length) _currentPage = max(0, _riverPrayers.length -1);

                      setState(() { /* _riverPrayers already modified */ });
                       WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && _pageController.hasClients) {
                              int targetPage = _currentPage;
                              if (_riverPrayers.isEmpty) targetPage = 0;
                              else if (targetPage >= _riverPrayers.length) targetPage = max(0, _riverPrayers.length - 1);
                              
                              if(_riverPrayers.isNotEmpty && _pageController.page?.round() != targetPage) {
                                  _pageController.jumpToPage(targetPage);
                              }
                          }
                      });
                  }
            }
         }
         _isUserInteractingWithPage = false;
         _resetAutoCycleTimer();
         return success;
      }
    ).then((_){
        if (mounted && _isUserInteractingWithPage) { // Check if _isUserInteractingWithPage was set back by other means
            _isUserInteractingWithPage = false; // Ensure it's false before resetting timer
             _resetAutoCycleTimer();
        } else if (mounted) {
            _resetAutoCycleTimer(); // If it was already false, still reset.
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User?>(context);
    final theme = Theme.of(context);

    const darkScreenGradient = LinearGradient(
      colors: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF253141)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Prayer Wall of Hope', style: theme.appBarTheme.titleTextStyle?.copyWith(color: Colors.white)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white.withOpacity(0.8)),
        actionsIconTheme: IconThemeData(color: Colors.white.withOpacity(0.8)),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: darkScreenGradient),
        child: SafeArea(
          bottom: false, // Allow FAB to potentially sit lower if not for bottom SizedBox
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: WellOfHopeWidget(key: _wellOfHopeWidgetStateKey, wellKey: _wellOfHopeKey),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 8.0), // Space below PageView items
                  child: _riverPrayers.isEmpty
                      ? Center(
                          child: (_prayerStreamSubscription == null && _riverPrayers.isEmpty && !Provider.of<PrayerService>(context, listen:false).toString().contains("Instance"))
                              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white70))
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.water_drop_outlined, size: 48, color: Colors.white54),
                                    const SizedBox(height: 16),
                                    Text(
                                      "The river is quiet for now.\nNew prayers will appear here.",
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
                                    ),
                                  ],
                                ),
                        )
                      : Listener(
                           onPointerDown: (_) {
                            if(mounted) {
                                _isUserInteractingWithPage = true; // Mark user interaction
                                _autoCycleTimer?.cancel();
                            }
                          },
                          // onPointerUp not used, _handlePageScroll is primary for resetting timer
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _riverPrayers.length,
                            itemBuilder: (context, index) {
                              final riverPrayer = _riverPrayers[index];
                              return Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.72, // Slightly wider cards
                                    minHeight: 60, // Adjusted min height based on shorter cards
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 6.0), // Reduced padding
                                    child: RiverPrayerItem(
                                      key: riverPrayer.itemKey,
                                      prayerRequest: riverPrayer.prayer,
                                      onTap: () => _handlePrayForRequest(riverPrayer),
                                      onLongPress: () => _handleReportPrayer(riverPrayer.prayer),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 35.0),
                child: Text(
                  _riverPrayers.isNotEmpty ? "Tap a prayer to send your support. Swipe to see more." : "Tap a prayer to send your support.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 70), // Space for the FAB
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // Raise FAB
        child: FloatingActionButton.extended(
          onPressed: () {
            if (currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please log in to submit a prayer.')));
              return;
            }
            _autoCycleTimer?.cancel();
            _isUserInteractingWithPage = true; // Mark interaction
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SubmitPrayerScreen()),
            ).then((_) {
              if(mounted) {
                  _isUserInteractingWithPage = false; // Clear interaction flag
                  _resetAutoCycleTimer();
              }
            });
          },
          label: const Text("Share a Prayer"),
          icon: const Icon(Icons.add_comment_outlined),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}