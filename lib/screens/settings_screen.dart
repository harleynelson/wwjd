// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:wwjd_app/database_helper.dart';

import '../daily_devotions.dart';   
// import 'package:wwjd_app/home_screen.dart'; // Not strictly needed for this screen's logic

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _devOptionsEnabled = false; 
  int _devTapCount = 0;

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Future<void> _handleForceNextDevotional() async {
    await forceNextDevotional();
    _showSnackBar("Next devotional will be shown on Home screen refresh.");
  }

  Future<void> _handleResetAllPlanProgress() async { // Renamed method for clarity
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reset All Plan Progress?"),
        content: const Text(
            "This will reset ALL progress (streaks, completed days, current day) for ALL reading plans. This action cannot be undone."),
        actions: [
          TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(ctx).pop(false)),
          TextButton(
            child: Text("Reset All Progress",
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Call the updated method in DatabaseHelper
        await _dbHelper.resetAllStreaksAndProgress(); 
        _showSnackBar("All reading plan progress and streaks have been reset.");
      } catch (e) {
        _showSnackBar("Error resetting plan progress: ${e.toString()}", isError: true);
      }
    }
  }

  void _onAppVersionTap() {
    _devTapCount++;
    if (_devTapCount >= 7 && !_devOptionsEnabled) {
      if (mounted) {
        setState(() { _devOptionsEnabled = true; });
        _showSnackBar("Developer Options Enabled!");
      }
    } else if (_devOptionsEnabled && _devTapCount >=10) { 
        if (mounted) {
            setState(() { _devOptionsEnabled = false; });
            _showSnackBar("Developer Options Disabled.");
            _devTapCount = 0; 
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("App Version"),
            subtitle: const Text("1.0.0 (WWJD Daily)"), 
            onTap: _onAppVersionTap, 
          ),
          const Divider(),
          // Add other general settings here

          if (_devOptionsEnabled) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // Added top padding
              child: Text(
                "Developer Options",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.skip_next_outlined, color: Colors.orange),
              title: const Text("Force Next Devotional"),
              subtitle: const Text("Shows the next devotional on Home screen refresh."),
              onTap: _handleForceNextDevotional,
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt_outlined, color: Colors.redAccent),
              title: const Text("Reset All Reading Plan Progress"), // Updated title
              subtitle: const Text("Resets streaks and all daily reading progress."), // Updated subtitle
              onTap: _handleResetAllPlanProgress, // Updated handler
            ),
            const Divider(),
          ],
        ],
      ),
    );
  }
}
