// File: lib/screens/my_prayer_requests_screen.dart
// Purpose: Allows users to view the status and interactions of prayers they've submitted
//          using their unique anonymous prayer ID.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard functionality.
import 'package:provider/provider.dart'; // To access PrayerService and User stream.
import 'package:shared_preferences/shared_preferences.dart'; // To store/retrieve anonymous ID locally.
import 'package:firebase_auth/firebase_auth.dart'; // To get current Firebase User.

import '../models/prayer_request_model.dart'; // Data model for prayer requests.
import '../services/prayer_service.dart'; // Service for fetching user's prayers.
import '../widgets/prayer_request_card.dart'; // Reusable widget to display each prayer.

class MyPrayerRequestsScreen extends StatefulWidget {
  static const routeName = '/my-prayers'; // Route name for navigation.

  const MyPrayerRequestsScreen({Key? key}) : super(key: key);

  @override
  State<MyPrayerRequestsScreen> createState() => _MyPrayerRequestsScreenState();
}

class _MyPrayerRequestsScreenState extends State<MyPrayerRequestsScreen> {
  final _anonymousIdController = TextEditingController(); // Controller for the ID input field.
  String? _currentSubmitterAnonymousId; // Stores the ID being used for the current query.
  Stream<List<PrayerRequest>>? _myPrayersStream; // Stream of the user's submitted prayers.
  bool _isLoadingId = true; // Tracks loading state for the initial ID retrieval.
  bool _idFoundInProfile = false; // Indicates if the ID was loaded from UserPrayerProfile.
  bool _hasSearched = false; // Tracks if a search has been performed.

  @override
  void initState() {
    super.initState();
    // Delay loading ID until after the first frame to ensure context is available for Provider.
    // This is important if PrayerService methods called in _loadSubmitterAnonymousId need context.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Check if widget is still in the tree
         _loadSubmitterAnonymousId();
      }
    });
  }

  // Attempts to load the user's submitterAnonymousId, first from their UserPrayerProfile,
  // then falling back to SharedPreferences.
  Future<void> _loadSubmitterAnonymousId() async {
    if (!mounted) return; 
    setState(() => _isLoadingId = true);

    final prayerService = Provider.of<PrayerService>(context, listen: false);
    final firebaseUser = Provider.of<User?>(context, listen: false); // Get Firebase user.
    String? idToUse;

    if (firebaseUser != null) {
      // If user is logged in, try to get the ID from their UserPrayerProfile via PrayerService.
      // This is the preferred method as it's linked to their account.
      try {
        // PrayerService.getCurrentUserSubmitterAnonymousId now requires context.
        idToUse = await prayerService.getCurrentUserSubmitterAnonymousId(context);
        if (idToUse != null && idToUse.isNotEmpty) {
          _idFoundInProfile = true; // Mark that ID was found in the user's profile.
           print("MyPrayerRequestsScreen: Loaded Anonymous ID from UserPrayerProfile: $idToUse");
        }
      } catch (e) {
        print("MyPrayerRequestsScreen: Could not load Anonymous ID from prayer profile: $e. Will try SharedPreferences.");
      }
    }

    // If ID wasn't found in the profile (or user not logged in for that check),
    // try loading from SharedPreferences (local storage).
    if (idToUse == null || idToUse.isEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      idToUse = prefs.getString('submitterAnonymousId');
      if (idToUse != null && idToUse.isNotEmpty) {
        _idFoundInProfile = false; // Mark that ID came from SharedPreferences.
        print("MyPrayerRequestsScreen: Loaded Anonymous ID from SharedPreferences: $idToUse");
      }
    }
    
    if (mounted) { // Check mount status again before setState.
      if (idToUse != null && idToUse.isNotEmpty) {
        setState(() {
          _currentSubmitterAnonymousId = idToUse;
          _anonymousIdController.text = idToUse!; // Pre-fill the input field.
          // Automatically fetch prayers if an ID was loaded.
          _fetchMyPrayers(idToUse!); 
        });
      } else {
         setState(() {
          _idFoundInProfile = false; // No ID found initially.
        });
      }
      setState(() => _isLoadingId = false);
    }
  }

  // Saves the provided anonymous ID to SharedPreferences.
  Future<void> _saveSubmitterAnonymousId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('submitterAnonymousId', id);
    print("MyPrayerRequestsScreen: Saved/Updated submitterAnonymousId in SharedPreferences: $id");
  }

  // Fetches prayers associated with the given anonymous ID.
  void _fetchMyPrayers(String anonymousId) {
    final String trimmedId = anonymousId.trim();
    if (trimmedId.isEmpty) {
      if (mounted) {
        setState(() {
          _myPrayersStream = Stream.value([]); // Show empty results if ID is empty.
          _hasSearched = true; // Mark that a search attempt was made.
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your Anonymous Prayer ID.')),
        );
      }
      return;
    }

    final prayerService = Provider.of<PrayerService>(context, listen: false);
    if (mounted) {
      setState(() {
        _currentSubmitterAnonymousId = trimmedId;
        _myPrayersStream = prayerService.getMySubmittedPrayers(trimmedId);
        _hasSearched = true; // Mark that a search has been performed.
      });
    }
    _saveSubmitterAnonymousId(trimmedId); // Save the ID used for search.
    FocusScope.of(context).unfocus(); // Dismiss keyboard after search.
  }

  @override
  void dispose() {
    _anonymousIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = Provider.of<User?>(context, listen: false); // For PrayerRequestCard interactions

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Submitted Prayers'),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Input section for the Anonymous Prayer ID.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter the Anonymous Prayer ID you received when you submitted a prayer. This allows you to see its status and how many people have prayed for it.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _anonymousIdController,
                        decoration: InputDecoration(
                          labelText: 'Your Anonymous Prayer ID',
                          hintText: 'Paste or type your ID',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          suffixIcon: _anonymousIdController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _anonymousIdController.clear();
                                  if (mounted) {
                                    setState(() {
                                      _myPrayersStream = null; 
                                      _currentSubmitterAnonymousId = null;
                                      _idFoundInProfile = false;
                                      _hasSearched = false;
                                    });
                                  }
                                  _saveSubmitterAnonymousId(""); // Clear saved ID.
                                },
                              )
                            : null,
                        ),
                        onSubmitted: (value) => _fetchMyPrayers(value), // Search on submit.
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled( // Using filled style for primary action
                      icon: const Icon(Icons.search),
                      tooltip: 'Load My Prayers',
                      onPressed: () => _fetchMyPrayers(_anonymousIdController.text),
                      style: IconButton.styleFrom(
                        // backgroundColor: theme.colorScheme.primary, // Handled by filled style
                        // foregroundColor: theme.colorScheme.onPrimary, // Handled by filled style
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ],
                ),
                // Display loading status or information about the ID.
                if (_isLoadingId)
                  const Padding(
                    padding: EdgeInsets.only(top:10.0),
                    child: Center(child: Text("Loading your saved ID...", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12))),
                  )
                else if (_currentSubmitterAnonymousId == null || _currentSubmitterAnonymousId!.isEmpty && !_hasSearched)
                   Padding(
                    padding: const EdgeInsets.only(top:10.0),
                    child: Text(
                      "No Anonymous ID found. If you've submitted a prayer before, enter the ID you received. Otherwise, submit a prayer first to get an ID.",
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                    ),
                  )
                else if (_currentSubmitterAnonymousId != null && _currentSubmitterAnonymousId!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Tracking ID: $_currentSubmitterAnonymousId${_idFoundInProfile ? ' (from your profile)' : ' (from local save)'}", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                          )
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_outlined, size: 18),
                          tooltip: 'Copy ID',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _currentSubmitterAnonymousId!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Your Anonymous Prayer ID copied to clipboard!')),
                            );
                          },
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
          const Divider(height: 1),
          // Display the list of prayers or relevant messages.
          Expanded(
            child: (_myPrayersStream == null && !_isLoadingId && !_hasSearched)
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                       _currentSubmitterAnonymousId == null || _currentSubmitterAnonymousId!.isEmpty
                        ? 'Enter your Anonymous Prayer ID above and tap search to view your submissions.'
                        : 'Loading prayers for your ID...', // Should not show if ID is loaded and stream is set
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  ))
                : StreamBuilder<List<PrayerRequest>>(
                    stream: _myPrayersStream, // Can be null if no search yet
                    builder: (context, snapshot) {
                      if (!_hasSearched && _currentSubmitterAnonymousId == null) {
                        // Initial state before any search or ID load attempt
                         return Center(child: Text('Enter your ID to begin.', style: TextStyle(color: Colors.grey.shade600)));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting && (_hasSearched || _isLoadingId)) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Error loading your prayers: ${snapshot.error}', textAlign: TextAlign.center),
                            ));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              (_currentSubmitterAnonymousId == null || _currentSubmitterAnonymousId!.isEmpty) && _hasSearched
                                ? 'Please enter a valid ID to search.'
                                : _hasSearched 
                                  ? 'No prayer requests found for this ID.\nThey might still be pending review, or the ID is incorrect. Please check back later!'
                                  : 'Enter your ID to see your prayers.', // Fallback if no ID and no search yet
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                            ),
                          ),
                        );
                      }

                      final prayers = snapshot.data!;
                      // For "My Prayers", interactions on the card might be disabled or different.
                      // The main purpose is to see status, text, and prayer counts.
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        itemCount: prayers.length,
                        itemBuilder: (context, index) {
                          // Pass currentUserId if you want to allow reporting/interacting with own prayers,
                          // though typically this screen is read-only for interactions.
                          return PrayerRequestCard(
                            prayerRequest: prayers[index],
                            currentUserId: currentUser?.uid, 
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
