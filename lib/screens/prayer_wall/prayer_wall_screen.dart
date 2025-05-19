// File: lib/screens/prayer_wall/prayer_wall_screen.dart
// Path: lib/screens/prayer_wall/prayer_wall_screen.dart
// Updated: Removed _buildPrayerStreakDisplay method and uses the new PrayerStreakDisplay widget.
// Updated: Import for RiverPrayerItem.

import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For formatting next available submission date

import '../../models/prayer_request_model.dart';
import '../../models/user_prayer_profile_model.dart';
import '../../services/prayer_service.dart';
// import '../../widgets/prayer_wall/prayer_request_card.dart'; // RiverPrayerItem is no longer here
import '../../widgets/prayer_wall/river_prayer_item.dart'; // MODIFIED IMPORT
import '../../widgets/prayer_wall/well_of_hope_widget.dart';
import '../../widgets/prayer_wall/animated_prayer_mote.dart';
import '../../widgets/prayer_wall/prayer_streak_display.dart'; // NEW IMPORT
import 'submit_prayer_screen.dart';
import '../../dialogs/prayer_report_dialog.dart';

class RiverPrayerVisual {
  final PrayerRequest prayer;
  final GlobalKey itemKey;
  final Animation<double>? animation;

  RiverPrayerVisual({required this.prayer, this.animation})
      : itemKey = GlobalKey();
}

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
  String? _animatingOutPrayerId;

  UserPrayerProfile? _currentUserPrayerProfile;
  bool _isLoadingStreak = true;
  StreamSubscription? _userAuthSubscription;
  User? _currentUser; // Local state to hold the current Firebase User

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.75,
      initialPage: _currentPage,
    );
    _pageController.addListener(_handlePageScroll);

    _currentUser = Provider.of<User?>(context, listen: false);

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

    _userAuthSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        bool userChanged = _currentUser?.uid != user?.uid;
        setState(() {
          _currentUser = user;
        });
        if (userChanged || _currentUserPrayerProfile == null) { // Fetch if user changed or profile not yet loaded
             _fetchUserPrayerStreakData();
        }
      }
    });

    _fetchUserPrayerStreakData();
  }

  Future<void> _fetchUserPrayerStreakData() async {
    if (!mounted) return;
    setState(() { _isLoadingStreak = true; });

    if (_currentUser != null) { // Works for anonymous or logged-in users
      final prayerService = Provider.of<PrayerService>(context, listen: false);
      _currentUserPrayerProfile = await prayerService.getUserPrayerProfile(_currentUser!.uid);
    } else {
      _currentUserPrayerProfile = null;
    }

    if (mounted) {
      setState(() { _isLoadingStreak = false; });
    }
  }

  void _handlePageScroll() { // Unchanged
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
  void dispose() { // Unchanged (except added _userAuthSubscription.cancel())
    _prayerStreamSubscription?.cancel();
    _userAuthSubscription?.cancel();
    _activeMoteAnimation?.controller.dispose();
    _moteOverlayEntry?.remove();
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    _autoCycleTimer?.cancel();
    super.dispose();
  }

  void _startAutoCycleTimer() { // Unchanged
    _autoCycleTimer?.cancel();
    if (!mounted || _riverPrayers.length <= 1) return;
    _autoCycleTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted || _isUserInteractingWithPage || !_pageController.hasClients || (_pageController.page != _pageController.page?.roundToDouble()) ) return;
       if (_animatingOutPrayerId != null) return;
      _isPageAnimatingProgrammatically = true;
      int nextPage = _currentPage + 1;
      if (nextPage >= _riverPrayers.length) { nextPage = 0; }
      _pageController.animateToPage( nextPage, duration: const Duration(milliseconds: 800), curve: Curves.easeInOutSine,);
    });
  }

  void _resetAutoCycleTimer() { // Unchanged
    _autoCycleTimer?.cancel();
    if(mounted && _riverPrayers.length > 1 && _animatingOutPrayerId == null) {
        _startAutoCycleTimer();
    }
  }

  void _updateRiverPrayersList(List<PrayerRequest> newPrayersFromStream) { // Unchanged
    if (!mounted) return;
     if (_animatingOutPrayerId != null) { return; }
    List<PrayerRequest> potentialPrayers = List.from(newPrayersFromStream);
    potentialPrayers.shuffle(_random);
    Set<String> animatingPrayerIds = {};
    if (_activeMoteAnimation != null) { animatingPrayerIds.add(_activeMoteAnimation!.prayerId); }
    if(_animatingOutPrayerId != null) { animatingPrayerIds.add(_animatingOutPrayerId!); }
    final filteredPotentialPrayers = potentialPrayers.where((p) => !animatingPrayerIds.contains(p.prayerId)).toList();
    List<RiverPrayerVisual> newVisuals = filteredPotentialPrayers.take(_maxRiverPrayersToShowAtOnce).map((p) => RiverPrayerVisual(prayer: p)).toList();
    bool listActuallyChanged = false;
    if (_riverPrayers.length != newVisuals.length) { listActuallyChanged = true;
    } else { for(int i = 0; i < _riverPrayers.length; i++) { if(_riverPrayers[i].prayer.prayerId != newVisuals[i].prayer.prayerId) { listActuallyChanged = true; break; } } }
    if (listActuallyChanged || (_riverPrayers.isEmpty && newVisuals.isNotEmpty) ) {
         setState(() {
            _riverPrayers = newVisuals;
            if (_currentPage >= _riverPrayers.length) { _currentPage = _riverPrayers.isNotEmpty ? max(0, _riverPrayers.length - 1) : 0; }
            WidgetsBinding.instance.addPostFrameCallback((_) { if(mounted && _pageController.hasClients) { int targetPage = _currentPage; if (_riverPrayers.isEmpty) { targetPage = 0; } else if (targetPage >= _riverPrayers.length) { targetPage = max(0, _riverPrayers.length - 1); } if (_pageController.page?.round() != targetPage) { _pageController.jumpToPage(targetPage); } } });
        });
    }
    _resetAutoCycleTimer();
  }

  void _handlePrayForRequest(RiverPrayerVisual riverPrayerVisual) {
    final prayerRequest = riverPrayerVisual.prayer;
    final prayerService = Provider.of<PrayerService>(context, listen: false);

    if (_activeMoteAnimation != null || _animatingOutPrayerId != null) {
      print("Prayer animation already in progress. Please wait.");
      return;
    }

    _autoCycleTimer?.cancel();
    _isUserInteractingWithPage = true;

    setState(() {
       _animatingOutPrayerId = prayerRequest.prayerId;
       _activeMoteAnimation = PrayerMoteAnimation(
        prayerId: prayerRequest.prayerId,
        controller: AnimationController( duration: const Duration(milliseconds: 1200), vsync: this,),
        startKey: riverPrayerVisual.itemKey,
        endKey: _wellOfHopeKey,
      );
    });

    _moteOverlayEntry = OverlayEntry(builder: (context) {
        final startRenderBox = riverPrayerVisual.itemKey.currentContext?.findRenderObject() as RenderBox?;
        final endRenderBox = _wellOfHopeKey.currentContext?.findRenderObject() as RenderBox?;
        if (startRenderBox == null || !startRenderBox.hasSize || endRenderBox == null || !endRenderBox.hasSize) {
            _activeMoteAnimation?.controller.dispose(); _activeMoteAnimation = null;
            WidgetsBinding.instance.addPostFrameCallback((_) {  _moteOverlayEntry?.remove(); _moteOverlayEntry = null; if (mounted && _animatingOutPrayerId == prayerRequest.prayerId) { setState(() { _animatingOutPrayerId = null; });  } });
            return const SizedBox.shrink();
        }
        final startOffset = startRenderBox.localToGlobal(Offset.zero);
        final endOffset = endRenderBox.localToGlobal(Offset(endRenderBox.size.width / 2, endRenderBox.size.height / 2));
        return AnimatedPrayerMote( progress: _activeMoteAnimation!.progress, startPosition: startOffset + Offset(startRenderBox.size.width /2, startRenderBox.size.height /2), endPosition: endOffset, prayerText: prayerRequest.prayerText, );
    });

    Overlay.of(context).insert(_moteOverlayEntry!);

    _activeMoteAnimation!.controller.forward().then((_) async {
      _moteOverlayEntry?.remove(); _moteOverlayEntry = null;
      _activeMoteAnimation?.controller.dispose(); _activeMoteAnimation = null;

      final wellState = _wellOfHopeWidgetStateKey.currentState;
      if (wellState != null) {
          final RenderBox? wellRenderBox = _wellOfHopeKey.currentContext?.findRenderObject() as RenderBox?;
          if (wellRenderBox != null && wellRenderBox.hasSize) { final wellCenterGlobal = wellRenderBox.localToGlobal(Offset(wellRenderBox.size.width /2, wellRenderBox.size.height /2)); (wellState as dynamic).triggerAbsorptionEffect(wellCenterGlobal); }
      }

      bool incrementSuccess = await prayerService.incrementPrayerCount(prayerRequest.prayerId);

      if(incrementSuccess && mounted) {
         if (_currentUser != null) {
            await _fetchUserPrayerStreakData();
         }
      }

      if(mounted){
        int removedIndex = _riverPrayers.indexWhere((p) => p.prayer.prayerId == prayerRequest.prayerId);
        if (removedIndex != -1) {
            _riverPrayers.removeAt(removedIndex);
            if (_currentPage >= removedIndex && _currentPage > 0) { _currentPage = max(0, _currentPage - 1); }
             if (_riverPrayers.isEmpty) _currentPage = 0; else if (_currentPage >= _riverPrayers.length) _currentPage = max(0, _riverPrayers.length -1);
            setState(() { _animatingOutPrayerId = null; });
            WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted && _pageController.hasClients) { int targetPage = _currentPage; if (_riverPrayers.isEmpty) targetPage = 0; else if (targetPage >= _riverPrayers.length) targetPage = max(0, _riverPrayers.length - 1); if(_riverPrayers.isNotEmpty && _pageController.page?.round() != targetPage) { _pageController.jumpToPage(targetPage); } else if (_riverPrayers.isEmpty && _pageController.page?.round() != 0) { } } });
        } else { setState(() { _animatingOutPrayerId = null; }); }
        _isUserInteractingWithPage = false; _resetAutoCycleTimer();
      }
    }).catchError((e) {
        print("Error during mote animation or post-animation: $e");
        if (mounted) { _moteOverlayEntry?.remove(); _moteOverlayEntry = null; _activeMoteAnimation?.controller.dispose(); _activeMoteAnimation = null; setState(() { _animatingOutPrayerId = null; });  _isUserInteractingWithPage = false; _resetAutoCycleTimer(); }
    });
  }

  void _handleReportPrayer(PrayerRequest prayerRequest) { // Unchanged from previous version
    final prayerService = Provider.of<PrayerService>(context, listen: false);
    if (_currentUser == null) { ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Please log in to report prayers.'))); return; }
    _autoCycleTimer?.cancel(); _isUserInteractingWithPage = true;
    showPrayerReportDialog( context: context, prayerId: prayerRequest.prayerId, currentUserId: _currentUser?.uid,
      onSubmitReport: (reason) async {
         if (_currentUser == null) { _isUserInteractingWithPage = false; _resetAutoCycleTimer(); return false; }
         bool success = await prayerService.reportPrayer(prayerRequest.prayerId, reason);
         if(mounted){
            ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(success ? 'Prayer reported.' : 'Failed to report.')));
            if(success){
                 int removedIndex = _riverPrayers.indexWhere((p) => p.prayer.prayerId == prayerRequest.prayerId);
                  if (removedIndex != -1) {
                      _riverPrayers.removeAt(removedIndex);
                      if (_currentPage >= removedIndex && _currentPage > 0) { _currentPage = max(0, _currentPage - 1); }
                      if (_riverPrayers.isEmpty) _currentPage = 0; else if (_currentPage >= _riverPrayers.length) _currentPage = max(0, _riverPrayers.length -1);
                      setState(() { /* _riverPrayers already modified */ });
                       WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted && _pageController.hasClients) { int targetPage = _currentPage; if (_riverPrayers.isEmpty) targetPage = 0; else if (targetPage >= _riverPrayers.length) targetPage = max(0, _riverPrayers.length - 1); if(_riverPrayers.isNotEmpty && _pageController.page?.round() != targetPage) { _pageController.jumpToPage(targetPage); } } });
                  } } }
         _isUserInteractingWithPage = false; _resetAutoCycleTimer(); return success;
      }
    ).then((_){ if (mounted && _isUserInteractingWithPage) {  _isUserInteractingWithPage = false; _resetAutoCycleTimer(); } else if (mounted) { _resetAutoCycleTimer();  } });
  }

  // REMOVED _buildPrayerStreakDisplay method. It's now a separate widget.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const darkScreenGradient = LinearGradient( colors: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF253141)], begin: Alignment.topCenter, end: Alignment.bottomCenter,);

    return Scaffold(
      appBar: AppBar( title: Text('Prayer Wall of Hope', style: theme.appBarTheme.titleTextStyle?.copyWith(color: Colors.white)), elevation: 0, backgroundColor: Colors.transparent, iconTheme: IconThemeData(color: Colors.white.withOpacity(0.8)), actionsIconTheme: IconThemeData(color: Colors.white.withOpacity(0.8)),),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: darkScreenGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // USE THE NEW WIDGET HERE
              PrayerStreakDisplay(
                isLoadingStreak: _isLoadingStreak,
                currentUserPrayerProfile: _currentUserPrayerProfile,
                isUserLoggedIn: _currentUser != null,
              ),
              Expanded( flex: 2, child: WellOfHopeWidget(key: _wellOfHopeWidgetStateKey, wellKey: _wellOfHopeKey),),
              Expanded(
                flex: 2,
                child: Container( padding: const EdgeInsets.only(bottom: 8.0),
                  child: _riverPrayers.isEmpty && _animatingOutPrayerId == null
                      ? Center( child: (_prayerStreamSubscription == null && _riverPrayers.isEmpty && !Provider.of<PrayerService>(context, listen:false).toString().contains("Instance")) ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white70)) : Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(Icons.water_drop_outlined, size: 48, color: Colors.white54), const SizedBox(height: 16), Text( "The river is quiet for now.\nNew prayers will appear here.", textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70), ), ], ),)
                      : Listener(
                           onPointerDown: (_) { if(mounted) { _isUserInteractingWithPage = true;  _autoCycleTimer?.cancel(); } },
                          child: PageView.builder( controller: _pageController, itemCount: _riverPrayers.length,
                            itemBuilder: (context, index) { if (index >= _riverPrayers.length) {  return const SizedBox.shrink(); } final riverPrayer = _riverPrayers[index];
                              return Center( child: ConstrainedBox( constraints: BoxConstraints( maxWidth: MediaQuery.of(context).size.width * 0.72,  minHeight: 60,  ),
                                  child: Padding( padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 6.0),
                                    child: RiverPrayerItem( // Ensure this uses the new import
                                      key: riverPrayer.itemKey,
                                      prayerRequest: riverPrayer.prayer,
                                      onTap: () => _handlePrayForRequest(riverPrayer),
                                      onLongPress: () => _handleReportPrayer(riverPrayer.prayer),
                                      animation: riverPrayer.animation,
                                      playExitAnimation: _animatingOutPrayerId == riverPrayer.prayer.prayerId,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
              Padding( padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 35.0), child: Text( _riverPrayers.isNotEmpty ? "Tap a prayer to send your support. Swipe to see more." : "Tap a prayer to send support.", textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),),),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding( padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            _autoCycleTimer?.cancel(); _isUserInteractingWithPage = true;
            Navigator.push( context, MaterialPageRoute(builder: (context) => const SubmitPrayerScreen()),
            ).then((success) {
              if(mounted) { _isUserInteractingWithPage = false;  _resetAutoCycleTimer();
                if (success == true) {
                  _fetchUserPrayerStreakData();
                }
              }
            });
          },
          label: const Text("Share a Prayer"), icon: const Icon(Icons.add_comment_outlined), backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
