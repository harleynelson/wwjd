// lib/models.dart
import '../helpers/database_helper.dart'; // Needed for Flag.fromUserDbMap

class Book {
  final String abbreviation; // e.g., "GEN"
  final String fullName;     // e.g., "Genesis"
  final String canonOrder;
  Book({
    required this.abbreviation,
    required this.fullName,
    required this.canonOrder,
    });
  }

class Verse {
  final String verseNumber;
  final String text;
  final String? verseID;
  final String? bookAbbr;
  final String? chapter;

  // Make constructor const if possible (all fields must be final)
  const Verse({
    required this.verseNumber,
    required this.text,
    this.verseID,
    this.bookAbbr,
    this.chapter,
  });
}

class Flag {
  final int id; // Negative for pre-built, Positive for user-defined in DB
  final String name;
  // This field is needed for the dialog state
  bool isSelected; // <--- MAKE SURE THIS LINE EXISTS

  Flag({
    required this.id,
    required this.name,
    // This optional named parameter needs to exist
    this.isSelected = false // <--- MAKE SURE THIS PART EXISTS IN THE CONSTRUCTOR
  });

  // Check if it's pre-built based on ID
  bool get isPrebuilt => id < 0;

  // Factory for user flags from DB map
  factory Flag.fromUserDbMap(Map<String, dynamic> map) {
    return Flag(
      id: map[DatabaseHelper.flagsColId] as int,
      name: map[DatabaseHelper.flagsColName] as String,
      // isSelected defaults to false when creating from DB map
    );
  }
}

// Define Pre-built Flags (This part should be okay)
final List<Flag> prebuiltFlags = [
  Flag(id: -1, name: "Love"),
  Flag(id: -2, name: "Family"),
  Flag(id: -3, name: "Gratitude"),
  Flag(id: -4, name: "Fear"),
  Flag(id: -5, name: "Retribution"),
  Flag(id: -6, name: "Encouragement"),
  Flag(id: -7, name: "Guidance"),
  Flag(id: -8, name: "Faith"),
  Flag(id: -9, name: "Hope"),
  Flag(id: -10, name: "Prayer"),
];

class FavoriteVerse {
  final String verseID;
  final String bookAbbr;
  final String chapter;
  final String verseNumber;
  final String verseText;
  final DateTime createdAt;
  final String bookCanonOrder; // Added for sorting
  List<Flag> assignedFlags;

  FavoriteVerse({
    required this.verseID,
    required this.bookAbbr,
    required this.chapter,
    required this.verseNumber,
    required this.verseText,
    required this.createdAt,
    required this.bookCanonOrder, // Added
    this.assignedFlags = const [],
  });

  // Update factory method
  factory FavoriteVerse.fromMapAndFlags({
    required Map<String, dynamic> favMap,
    required List<Flag> flags,
    required String canonOrder, // Require canonOrder
  }) {
    return FavoriteVerse(
      verseID: favMap[DatabaseHelper.favColVerseID] as String,
      bookAbbr: favMap[DatabaseHelper.favColBookAbbr] as String,
      chapter: favMap[DatabaseHelper.favColChapter].toString(),
      verseNumber: favMap[DatabaseHelper.favColVerseNumber].toString(),
      verseText: favMap[DatabaseHelper.favColVerseText] as String,
      createdAt: DateTime.tryParse(favMap[DatabaseHelper.favColCreatedAt] as String? ?? '') ?? DateTime.now(),
      assignedFlags: flags,
      bookCanonOrder: canonOrder, // Assign it
    );
  }

  String getReference(String Function(String) getFullName) {
      return "${getFullName(bookAbbr)} $chapter:$verseNumber";
  }
}


class BiblePassagePointer {
  final String bookAbbr;
  final int startChapter;
  final int startVerse;
  final int endChapter;
  final int endVerse;
  final String displayText; // e.g., "Matthew 5:1-16" or "Genesis 1"

  const BiblePassagePointer({
    required this.bookAbbr,
    required this.startChapter,
    required this.startVerse,
    required this.endChapter,
    required this.endVerse,
    required this.displayText,
  });

  // For JSON serialization if storing progress with passage details
  Map<String, dynamic> toJson() => {
        'bookAbbr': bookAbbr,
        'startChapter': startChapter,
        'startVerse': startVerse,
        'endChapter': endChapter,
        'endVerse': endVerse,
        'displayText': displayText,
      };

  factory BiblePassagePointer.fromJson(Map<String, dynamic> json) => BiblePassagePointer(
        bookAbbr: json['bookAbbr'],
        startChapter: json['startChapter'],
        startVerse: json['startVerse'],
        endChapter: json['endChapter'],
        endVerse: json['endVerse'],
        displayText: json['displayText'],
      );
}

class ReadingPlanDay {
  final int dayNumber;
  final String title; // Optional title for the day's reading
  final List<BiblePassagePointer> passages;
  final String? reflectionPrompt; // Optional prompt for journaling
  // final String? devotionalId; // Optional: Link to a specific devotional from your list

  const ReadingPlanDay({
    required this.dayNumber,
    this.title = '',
    required this.passages,
    this.reflectionPrompt,
    // this.devotionalId,
  });
}

class ReadingPlan {
  final String id;
  final String title;
  final String description;
  final int durationDays; // Calculated or stored
  final String category; // e.g., "Gospels", "Topical", "Old Testament"
  final String? headerImageAssetPath; // Optional header image for the plan
  final bool isPremium;
  final List<ReadingPlanDay> dailyReadings;

  const ReadingPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.headerImageAssetPath,
    required this.isPremium,
    required this.dailyReadings,
  }) : durationDays = dailyReadings.length;
}

// Model for user's progress in a reading plan
class UserReadingProgress {
  final String planId;
  int currentDayNumber; // Next day to read (starts at 1)
  Map<int, DateTime> completedDays; // Map of dayNumber to completion DateTime
  DateTime startDate;
  DateTime? lastCompletionDate; // Tracks the date of the last completed reading
  int streakCount;
  bool isActive; // If the user is currently active on this plan

  UserReadingProgress({
    required this.planId,
    this.currentDayNumber = 1,
    Map<int, DateTime>? completedDays,
    required this.startDate,
    this.lastCompletionDate,
    this.streakCount = 0,
    this.isActive = true,
  }) : completedDays = completedDays ?? {};

  factory UserReadingProgress.fromMap(Map<String, dynamic> map) {
    Map<int, DateTime> completed = {};
    if (map['completed_days_json'] != null) {
      Map<String, String> storedMap = Map<String, String>.from(DatabaseHelper.decodeJson(map['completed_days_json']));
      storedMap.forEach((key, value) {
        completed[int.parse(key)] = DateTime.parse(value);
      });
    }

    return UserReadingProgress(
      planId: map[DatabaseHelper.progressColPlanId],
      currentDayNumber: map[DatabaseHelper.progressColCurrentDay],
      completedDays: completed,
      startDate: DateTime.parse(map[DatabaseHelper.progressColStartDate]),
      lastCompletionDate: map[DatabaseHelper.progressColLastCompletionDate] != null
          ? DateTime.parse(map[DatabaseHelper.progressColLastCompletionDate])
          : null,
      streakCount: map[DatabaseHelper.progressColStreakCount],
      isActive: map[DatabaseHelper.progressColIsActive] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, String> completedJson = {};
    completedDays.forEach((key, value) {
      completedJson[key.toString()] = value.toIso8601String();
    });

    return {
      DatabaseHelper.progressColPlanId: planId,
      DatabaseHelper.progressColCurrentDay: currentDayNumber,
      DatabaseHelper.progressColCompletedDaysJson: DatabaseHelper.encodeJson(completedJson),
      DatabaseHelper.progressColStartDate: startDate.toIso8601String(),
      DatabaseHelper.progressColLastCompletionDate: lastCompletionDate?.toIso8601String(),
      DatabaseHelper.progressColStreakCount: streakCount,
      DatabaseHelper.progressColIsActive: isActive ? 1 : 0,
    };
  }
}