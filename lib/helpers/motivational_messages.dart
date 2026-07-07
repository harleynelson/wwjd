// File: lib/helpers/motivational_messages.dart
// Description: Encouraging messages for engagement

import 'dart:math';

class MotivationalMessages {
  static final Random _random = Random();

  // --- Day Completion Celebrations ---
  static const List<String> _dayCompletionTitles = [
    'You\'re Growing! 🌱',
    'Day Complete! ✨',
    'Well Done! 🙌',
    'Keep Going! 🔥',
    'God Is Smiling! 😊',
    'Another Step! 🕊️',
    'Faithful & True! 💪',
    'You Did It! 🎉',
    'Growing in Grace! 🌿',
    'Strength for Today! ⚡',
    'Walking in Wisdom! 📖',
    'Blessed & Refreshed! 💧',
    'Light Breaking Through! ☀️',
    'Anchored in Hope! ⚓',
    'Spirit-Filled Moment! 🕯️',
  ];

  static const List<String> _dayCompletionSubtitles = [
    'Every day in the Word is a day well spent.',
    'You\'re building a habit that transforms lives — starting with yours.',
    'The Word is taking root in your heart. Beautiful things are growing.',
    'Small steps, big faith. You\'re right where you need to be.',
    'Heaven is cheering you on right now.',
    'Consistency compounds. Today you planted seeds that will bloom.',
    'Your future self is thanking you for showing up today.',
    'There\'s power in every page. You just unlocked more of it.',
    'Don\'t stop now — you\'re on the verge of a breakthrough.',
    'The best investment you can make is in your spirit. Well invested.',
    'Scripture isn\'t just read — it\'s lived. And you\'re living it.',
    'This is where transformation happens — one day at a time.',
    'Your dedication today is someone else\'s inspiration tomorrow.',
    'God\'s Word never returns void. Today\'s reading will bear fruit.',
    'You showed up. That\'s half the battle. The Spirit does the rest.',
  ];

  // --- Plan Completion Celebrations ---
  static const List<String> _planCompletionTitles = [
    'Plan Completed! 🏆',
    'Victory in the Word! 🎊',
    'You Finished Strong! 💪',
    'A New Chapter Begins! 📖',
    'Transformed & Renewed! 🔥',
  ];

  static const List<String> _planCompletionSubtitles = [
    'You just completed an entire reading plan! That\'s not just discipline — that\'s devotion. Take a moment to celebrate what God has done in your heart through this journey.',
    'Finishing a plan isn\'t the end — it\'s a launching pad. You\'ve built spiritual muscle that will carry you into your next season.',
    'Look at you! From Day 1 to the finish line. Every passage you read has been shaping you into who you\'re becoming.',
    'This is what commitment looks like. Not perfection — just showing up, day after day. And you did it!',
    'The Word has been working in you in ways you can see and in ways you can\'t yet see. Trust the process. Celebrate the milestone.',
  ];

  // --- Streak Milestones ---
  static const Map<int, List<String>> _streakMilestones = {
    3: [
      '3-Day Streak! 🔥', 'You\'re building momentum! Three days in a row — that\'s how habits are born.',
    ],
    7: [
      '1 Week Streak! 🎉', 'A full week in the Word! Research says it takes 21 days to form a habit — you\'re 1/3 of the way there!',
    ],
    14: [
      '2 Week Streak! ⚡', 'Two weeks of daily reading! You\'re officially a consistent Bible reader. This is who you are now.',
    ],
    21: [
      '21-Day Streak! 🏆', 'Three weeks! Science says the habit is formed. Your spirit says this is just the beginning.',
    ],
    30: [
      '30-Day Streak! 👑', 'A WHOLE MONTH in God\'s Word! You\'re not just reading — you\'re being transformed. This is legendary.',
    ],
    60: [
      '60-Day Streak! 🌟', 'Two months of daily devotion. Most people don\'t make it this far. You\'re not most people.',
    ],
    90: [
      '90-Day Streak! 💎', 'Three months. A quarter of a year. You\'ve built something unshakeable. Keep shining!',
    ],
  };

  // --- Daily Encouragement (shown on home screen or list) ---
  static const List<String> _dailyEncouragements = [
    'Your next breakthrough is one reading away.',
    'God meets you in these pages. Show up and see.',
    'The Word is alive. Let it breathe into your day.',
    'You\'re not just reading — you\'re being rewritten.',
    'Every scroll through Scripture is a step toward purpose.',
    'What you feed grows. Feed your spirit today.',
    'Your best days start with the Word. Let\'s go!',
    'The same God who spoke galaxies into existence wants to speak to you.',
  ];

  // --- Public API ---

  /// Returns (title, subtitle) for a day completion celebration.
  static (String, String) getDayCompletionMessage() {
    return (
      _dayCompletionTitles[_random.nextInt(_dayCompletionTitles.length)],
      _dayCompletionSubtitles[_random.nextInt(_dayCompletionSubtitles.length)],
    );
  }

  /// Returns (title, subtitle) for a plan completion celebration.
  static (String, String) getPlanCompletionMessage() {
    return (
      _planCompletionTitles[_random.nextInt(_planCompletionTitles.length)],
      _planCompletionSubtitles[_random.nextInt(_planCompletionSubtitles.length)],
    );
  }

  /// Returns a streak milestone message if the streak count hits a milestone, or null.
  static List<String>? getStreakMilestoneMessage(int streakCount) {
    return _streakMilestones[streakCount];
  }

  /// Returns a random daily encouragement.
  static String getDailyEncouragement() {
    return _dailyEncouragements[_random.nextInt(_dailyEncouragements.length)];
  }

  /// Returns streak-appropriate encouragement text.
  static String getStreakEncouragement(int streakCount) {
    if (streakCount >= 90) return 'Unstoppable! 👑';
    if (streakCount >= 60) return 'Legendary! 🌟';
    if (streakCount >= 30) return 'On Fire! 🔥';
    if (streakCount >= 21) return 'Habit Formed! 💪';
    if (streakCount >= 14) return 'Momentum! ⚡';
    if (streakCount >= 7) return 'Week Strong! 🎉';
    if (streakCount >= 3) return 'Building! 🌱';
    if (streakCount >= 1) return 'Day 1! 🚀';
    return 'Start Your Streak! ✨';
  }
}
