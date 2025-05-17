// File: lib/screens/prayer_wall/prayer_wall_screen.dart
// Path: lib/screens/prayer_wall/prayer_wall_screen.dart
// Updated: Removed anonymous check for praying, refined streak display logic.

import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For formatting next available submission date

import '../../models/prayer_request_model.dart';
import '../../models/user_prayer_profile_model.dart';
import '../../services/prayer_service.dart';
import '../../widgets/prayer_wall/prayer_request_card.dart';
import '../../widgets/prayer_wall/well_of_hope_widget.dart';
import '../../widgets/prayer_wall/animated_prayer_mote.dart';
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
    
    // Allow praying even if _currentUser is null (fully anonymous device, no Firebase anon UID yet)
    // OR if user is a Firebase anonymous user, OR a fully signed-in user.
    // PrayerService.incrementPrayerCount will handle based on _currentUser.uid (which will be an anon UID if applicable)
    // The streak will only update if _currentUser.uid is available.

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

    _moteOverlayEntry = OverlayEntry(builder: (context) { /* ... Mote Overlay logic unchanged ... */ 
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
      if (wellState != null) { /* ... Well absorption effect logic unchanged ... */ 
          final RenderBox? wellRenderBox = _wellOfHopeKey.currentContext?.findRenderObject() as RenderBox?;
          if (wellRenderBox != null && wellRenderBox.hasSize) { final wellCenterGlobal = wellRenderBox.localToGlobal(Offset(wellRenderBox.size.width /2, wellRenderBox.size.height /2)); (wellState as dynamic).triggerAbsorptionEffect(wellCenterGlobal); }
      }
      
      // PrayerService.incrementPrayerCount will now handle streak update if _currentUser is available
      bool incrementSuccess = await prayerService.incrementPrayerCount(prayerRequest.prayerId);
      
      if(incrementSuccess && mounted) { // Fetch streak data IF a user (anonymous or logged-in) context was available for the increment
         if (_currentUser != null) {
            await _fetchUserPrayerStreakData();
         }
      }

      if(mounted){ /* ... rest of the UI update logic after mote animation unchanged ... */ 
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
    }).catchError((e) { /* ... Error handling unchanged ... */ 
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

  Widget _buildPrayerStreakDisplay(BuildContext context) {
    if (_isLoadingStreak) {
      return const Padding( padding: EdgeInsets.all(8.0), child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))),);
    }
    // Show streak if a profile exists (could be for an anonymous or logged-in user)
    // Don't show if _currentUser is null (edge case, implies no user session at all)
    if (_currentUser == null || _currentUserPrayerProfile == null) {
      return Padding( // Show a generic encouragement if no user/profile to track streak for
        padding: const EdgeInsets.only(top: 8.0, bottom: 0),
        child: Text(
          "Tap a prayer below to send support!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.6)),
        ),
      );
    }

    final streak = _currentUserPrayerProfile!.currentPrayerStreak;
    final prayersToday = _currentUserPrayerProfile!.prayersSentOnStreakDay;
    final totalPrayersSent = _currentUserPrayerProfile!.totalPrayersSent;

    // If user has never prayed for anyone (totalPrayersSent is 0)
    if (totalPrayersSent == 0) {
       return Padding(
         padding: const EdgeInsets.only(top: 8.0, bottom: 0),
         child: Text(
           "Tap a prayer below to send support and start your prayer streak!",
           textAlign: TextAlign.center,
           style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.6)),
         ),
       );
    }
    
    // If they have prayed before, show streak (even if current streak is 0)
    if (streak > 0 || prayersToday > 0 || totalPrayersSent > 0) {
      bool isTodayStreakDay = false;
      if (_currentUserPrayerProfile?.lastPrayerStreakTimestamp != null) {
          final lastStreakDate = _currentUserPrayerProfile!.lastPrayerStreakTimestamp!.toDate();
          final nowDate = DateTime.now();
          isTodayStreakDay = lastStreakDate.year == nowDate.year &&
                             lastStreakDate.month == nowDate.month &&
                             lastStreakDate.day == nowDate.day;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_fire_department_rounded, color: streak > 0 ? Colors.orangeAccent.shade100 : Colors.white54, size: 22),
            const SizedBox(width: 8),
            Text(
              "$streak Day Prayer Streak",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (prayersToday > 0 && isTodayStreakDay) ...[ 
              const SizedBox(width: 4),
              Text(
                "($prayersToday today)",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ]
          ],
        ),
      );
    }
    // Fallback if conditions not met (e.g., data inconsistency, though unlikely with above logic)
     return Padding(
       padding: const EdgeInsets.only(top: 8.0, bottom: 0),
       child: Text(
         "Keep the prayers flowing to build your streak!",
         textAlign: TextAlign.center,
         style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.6)),
       ),
     );
  }

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
              _buildPrayerStreakDisplay(context), 
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
                                    child: RiverPrayerItem( key: riverPrayer.itemKey,  prayerRequest: riverPrayer.prayer, onTap: () => _handlePrayForRequest(riverPrayer), onLongPress: () => _handleReportPrayer(riverPrayer.prayer), animation: riverPrayer.animation,  playExitAnimation: _animatingOutPrayerId == riverPrayer.prayer.prayerId, ),),),);
                            }, ),),),),
              Padding( padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 35.0), child: Text( _riverPrayers.isNotEmpty ? "Tap a prayer to send your support. Swipe to see more." : "Tap a prayer to send support.", textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),),),
              const SizedBox(height: 70), 
            ],),),),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding( padding: const EdgeInsets.only(bottom: 16.0), 
        child: FloatingActionButton.extended(
          onPressed: () {
            // User doesn't need to be "fully" logged in to submit, AuthService ensures an anonymous user.
            // The submitPrayer method in PrayerService handles limits.
            _autoCycleTimer?.cancel(); _isUserInteractingWithPage = true; 
            Navigator.push( context, MaterialPageRoute(builder: (context) => const SubmitPrayerScreen()),
            ).then((success) { // submit_prayer_screen now pops with bool
              if(mounted) { _isUserInteractingWithPage = false;  _resetAutoCycleTimer();
                if (success == true) { // If a prayer was successfully submitted
                  _fetchUserPrayerStreakData(); // Refresh streak data, as submission limit might have changed
                }
              }
            });
          },
          label: const Text("Share a Prayer"), icon: const Icon(Icons.add_comment_outlined), backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary,
        ),),);
  }
}