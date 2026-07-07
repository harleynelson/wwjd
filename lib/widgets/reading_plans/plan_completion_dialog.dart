// File: lib/widgets/reading_plans/plan_completion_dialog.dart
// Description: Celebration dialog for finishing a plan

import 'package:flutter/material.dart';
import '../../helpers/motivational_messages.dart';

class PlanCompletionDialog extends StatefulWidget {
  final String planTitle;
  final int totalDays;
  final int streakCount;
  final VoidCallback? onRestart;
  final VoidCallback? onExploreMore;

  const PlanCompletionDialog({
    super.key,
    required this.planTitle,
    required this.totalDays,
    this.streakCount = 0,
    this.onRestart,
    this.onExploreMore,
  });

  static void show(
    BuildContext context, {
    required String planTitle,
    required int totalDays,
    int streakCount = 0,
    VoidCallback? onRestart,
    VoidCallback? onExploreMore,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PlanCompletionDialog(
        planTitle: planTitle,
        totalDays: totalDays,
        streakCount: streakCount,
        onRestart: onRestart,
        onExploreMore: onExploreMore,
      ),
    );
  }

  @override
  State<PlanCompletionDialog> createState() => _PlanCompletionDialogState();
}

class _PlanCompletionDialogState extends State<PlanCompletionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = MotivationalMessages.getPlanCompletionMessage();
    final theme = Theme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.25),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
              border: Border.all(
                color: Colors.amber.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy emoji
                const Text('🏆📖✨', style: TextStyle(fontSize: 52), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Plan name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.planTitle,
                    style: TextStyle(
                      color: Colors.amber.shade200,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatBadge('${widget.totalDays}', 'Days'),
                    const SizedBox(width: 16),
                    _buildStatBadge('${widget.streakCount}', 'Streak'),
                    const SizedBox(width: 16),
                    _buildStatBadge('100%', 'Complete'),
                  ],
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onExploreMore?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Explore More'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onRestart?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Start Fresh 🔄'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
