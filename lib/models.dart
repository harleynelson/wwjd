// lib/models.dart
import 'database_helper.dart'; // Needed for Flag.fromUserDbMap

class Book {
  final String abbreviation;
  final String fullName;
  // Make constructor const
  const Book({required this.abbreviation, required this.fullName});
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