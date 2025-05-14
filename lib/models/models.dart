// lib/models/models.dart
// Path: lib/models/models.dart
// Approximate line: Entire File (Significant Changes)

import '../helpers/database_helper.dart'; // Needed for Flag.fromUserDbMap
import 'dart:convert'; // Required for jsonEncode/Decode if used directly in models, though usually handled by serialization logic

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

  const Verse({
    required this.verseNumber,
    required this.text,
    this.verseID,
    this.bookAbbr,
    this.chapter,
  });
}

class Flag {
  final int id;
  final String name;
  bool isSelected;

  Flag({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  bool get isPrebuilt => id < 0;

  factory Flag.fromUserDbMap(Map<String, dynamic> map) {
    return Flag(
      id: map[DatabaseHelper.flagsColId] as int,
      name: map[DatabaseHelper.flagsColName] as String,
    );
  }
}

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
  final String bookCanonOrder;
  List<Flag> assignedFlags;

  FavoriteVerse({
    required this.verseID,
    required this.bookAbbr,
    required this.chapter,
    required this.verseNumber,
    required this.verseText,
    required this.createdAt,
    required this.bookCanonOrder,
    this.assignedFlags = const [],
  });

  factory FavoriteVerse.fromMapAndFlags({
    required Map<String, dynamic> favMap,
    required List<Flag> flags,
    required String canonOrder,
  }) {
    return FavoriteVerse(
      verseID: favMap[DatabaseHelper.favColVerseID] as String,
      bookAbbr: favMap[DatabaseHelper.favColBookAbbr] as String,
      chapter: favMap[DatabaseHelper.favColChapter].toString(),
      verseNumber: favMap[DatabaseHelper.favColVerseNumber].toString(),
      verseText: favMap[DatabaseHelper.favColVerseText] as String,
      createdAt: DateTime.tryParse(favMap[DatabaseHelper.favColCreatedAt] as String? ?? '') ?? DateTime.now(),
      assignedFlags: flags,
      bookCanonOrder: canonOrder,
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
  final String displayText;

  const BiblePassagePointer({
    required this.bookAbbr,
    required this.startChapter,
    required this.startVerse,
    required this.endChapter,
    required this.endVerse,
    required this.displayText,
  });

  Map<String, dynamic> toJson() => {
        'bookAbbr': bookAbbr,
        'startChapter': startChapter,
        'startVerse': startVerse,
        'endChapter': endChapter,
        'endVerse': endVerse,
        'displayText': displayText,
      };

  factory BiblePassagePointer.fromJson(Map<String, dynamic> json) => BiblePassagePointer(
        bookAbbr: json['bookAbbr'] as String,
        startChapter: json['startChapter'] as int,
        startVerse: json['startVerse'] as int,
        endChapter: json['endChapter'] as int,
        endVerse: json['endVerse'] as int,
        displayText: json['displayText'] as String,
      );
}

class InterspersedInsight {
  final int afterPassageIndex;
  final String text;
  final String? attribution;

  const InterspersedInsight({
    required this.afterPassageIndex,
    required this.text,
    this.attribution,
  });

  Map<String, dynamic> toJson() => {
        'afterPassageIndex': afterPassageIndex,
        'text': text,
        'attribution': attribution,
      };

  factory InterspersedInsight.fromJson(Map<String, dynamic> json) => InterspersedInsight(
        afterPassageIndex: json['afterPassageIndex'] as int,
        text: json['text'] as String,
        attribution: json['attribution'] as String?,
      );
}

class ReadingPlanDay {
  final int dayNumber;
  final String title;
  final List<BiblePassagePointer> passages;
  final String? reflectionPrompt;
  final List<InterspersedInsight> interspersedInsights;

  const ReadingPlanDay({
    required this.dayNumber,
    this.title = '',
    required this.passages,
    this.reflectionPrompt,
    this.interspersedInsights = const [],
  });

  factory ReadingPlanDay.fromJson(Map<String, dynamic> json) {
    var passagesList = json['passages'] as List? ?? [];
    List<BiblePassagePointer> passages = passagesList
        .map((p) => BiblePassagePointer.fromJson(p as Map<String, dynamic>))
        .toList();

    var insightsList = json['interspersedInsights'] as List? ?? [];
    List<InterspersedInsight> insights = insightsList
        .map((i) => InterspersedInsight.fromJson(i as Map<String, dynamic>))
        .toList();

    return ReadingPlanDay(
      dayNumber: json['dayNumber'] as int,
      title: json['title'] as String? ?? '',
      passages: passages,
      reflectionPrompt: json['reflectionPrompt'] as String?,
      interspersedInsights: insights,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'title': title,
      'passages': passages.map((p) => p.toJson()).toList(),
      'reflectionPrompt': reflectionPrompt,
      'interspersedInsights':
          interspersedInsights.map((i) => i.toJson()).toList(),
    };
  }
}

class ReadingPlan {
  final String id;
  final String title;
  final String description;
  final int durationDays;
  final String category;
  final String? headerImageAssetPath;
  final bool isPremium;
  final List<ReadingPlanDay> dailyReadings;
  final int version; // Added for updates, default to 1

  ReadingPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.headerImageAssetPath,
    required this.isPremium,
    required this.dailyReadings,
    this.version = 1, // Default version to 1
  }) : durationDays = dailyReadings.length;

  factory ReadingPlan.fromJson(Map<String, dynamic> json) {
    var readingsList = json['dailyReadings'] as List? ?? [];
    List<ReadingPlanDay> readings = readingsList
        .map((r) => ReadingPlanDay.fromJson(r as Map<String, dynamic>))
        .toList();

    return ReadingPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      headerImageAssetPath: json['headerImageAssetPath'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      dailyReadings: readings,
      version: json['version'] as int? ?? 1, // Default to 1 if not present
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationDays': durationDays,
      'category': category,
      'headerImageAssetPath': headerImageAssetPath,
      'isPremium': isPremium,
      'dailyReadings': dailyReadings.map((r) => r.toJson()).toList(),
      'version': version,
    };
  }
}

class UserReadingProgress {
  final String planId;
  int currentDayNumber;
  Map<int, DateTime> completedDays;
  DateTime startDate;
  DateTime? lastCompletionDate;
  int streakCount;
  bool isActive;

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