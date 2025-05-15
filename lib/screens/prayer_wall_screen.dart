// File: lib/screens/prayer_wall_screen.dart
// Purpose: Displays a list of approved prayer requests from Firestore.
// Users can view prayers and navigate to submit their own.

import 'package:firebase_auth/firebase_auth.dart'; // To get current Firebase User.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // To access PrayerService and User stream.

import '../models/prayer_request_model.dart'; // Data model for prayer requests.
import '../services/prayer_service.dart'; // Service for fetching prayers.
import '../widgets/prayer_request_card.dart'; // Widget to display each prayer.
import './submit_prayer_screen.dart'; // Screen to submit a new prayer.

class PrayerWallScreen extends StatefulWidget {
  static const routeName = '/prayer-wall'; // Route name for navigation.

  const PrayerWallScreen({Key? key}) : super(key: key);

  @override
  State<PrayerWallScreen> createState() => _PrayerWallScreenState();
}

class _PrayerWallScreenState extends State<PrayerWallScreen> {
  // TODO: Implement pull-to-refresh functionality if desired.
  // final RefreshController _refreshController = RefreshController(initialRefresh: false);

  // void _onRefresh() async {
  //   // Monitor network fetch
  //   await Future.delayed(Duration(milliseconds: 1000)); // Simulate network delay
  //   // if failed,use _refreshController.refreshFailed()
  //   if (mounted) setState(() {}); // Trigger rebuild to fetch fresh data via StreamBuilder
  //   _refreshController.refreshCompleted();
  // }

  @override
  Widget build(BuildContext context) {
    final prayerService = Provider.of<PrayerService>(context, listen: false);
    final currentUser = Provider.of<User?>(context); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Wall'),
        elevation: 1, 
      ),
      body: StreamBuilder<List<PrayerRequest>>(
        stream: prayerService.getApprovedPrayers(limit: 30), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("PrayerWallScreen StreamBuilder Error: ${snapshot.error}");
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading prayers: ${snapshot.error}.\nPlease check your internet connection and try again.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.forum_outlined, size: 60, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'No prayer requests yet.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to share a prayer with the community, or check back soon!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          final prayers = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80), 
            itemCount: prayers.length,
            itemBuilder: (context, index) {
              return PrayerRequestCard(
                prayerRequest: prayers[index],
                currentUserId: currentUser?.uid, 
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async { // Make onPressed async
          if (currentUser == null) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please log in to submit a prayer.')));
            return;
          }
          // Navigate using MaterialPageRoute and await a result
          final result = await Navigator.push<bool>( // Expect a boolean result
            context,
            MaterialPageRoute(builder: (context) => const SubmitPrayerScreen()),
          );

          // Check if the widget is still mounted and if submission was successful
          if (result == true && mounted) { 
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Prayer submitted for review! Why not pray for others while you wait?'),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
            // Optionally, you could refresh the prayer list here if needed,
            // though new prayers go to pending and won't appear immediately.
          }
        },
        label: const Text('Add Prayer'),
        icon: const Icon(Icons.add_comment_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }}
