// File: lib/helpers/book_names.dart
// Path: lib/helpers/book_names.dart
// Updated: Added bookNameToAbbr function.

const Map<String, String> bookCodeToFullName = {
  "GEN": "Genesis", "EXO": "Exodus", "LEV": "Leviticus", "NUM": "Numbers",
  "DEU": "Deuteronomy", "JOS": "Joshua", "JDG": "Judges", "RUT": "Ruth",
  "1SA": "1 Samuel", "2SA": "2 Samuel", "1KI": "1 Kings", "2KI": "2 Kings",
  "1CH": "1 Chronicles", "2CH": "2 Chronicles", "EZR": "Ezra", "NEH": "Nehemiah",
  "EST": "Esther", "JOB": "Job", "PSA": "Psalms", "PRO": "Proverbs",
  "ECC": "Ecclesiastes", "SNG": "Song of Solomon", "ISA": "Isaiah",
  "JER": "Jeremiah", "LAM": "Lamentations", "EZK": "Ezekiel", "DAN": "Daniel",
  "HOS": "Hosea", "JOL": "Joel", "AMO": "Amos", "OBA": "Obadiah", "JON": "Jonah",
  "MIC": "Micah", "NAM": "Nahum", "HAB": "Habakkuk", "ZEP": "Zephaniah",
  "HAG": "Haggai", "ZEC": "Zechariah", "MAL": "Malachi",
  "MAT": "Matthew", "MRK": "Mark", "LUK": "Luke", "JHN": "John",
  "ACT": "Acts", "ROM": "Romans", "1CO": "1 Corinthians", "2CO": "2 Corinthians",
  "GAL": "Galatians", "EPH": "Ephesians", "PHP": "Philippians",
  "COL": "Colossians", "1TH": "1 Thessalonians", "2TH": "2 Thessalonians",
  "1TI": "1 Timothy", "2TI": "2 Timothy", "TIT": "Titus", "PHM": "Philemon",
  "HEB": "Hebrews", "JAS": "James", "1PE": "1 Peter", "2PE": "2 Peter",
  "1JN": "1 John", "2JN": "2 John", "3JN": "3 John", "JUD": "Jude",
  "REV": "Revelation"
};

String getFullBookName(String bookCode) {
  return bookCodeToFullName[bookCode.toUpperCase()] ?? bookCode;
}

// --- NEW FUNCTION ---
// Function to get abbreviation from full book name (simple reverse lookup)
// This is a basic implementation and might need to be more robust
// for variations in full book names (e.g., "Song of Songs" vs "Song of Solomon").
String bookNameToAbbr(String fullName) {
  final upperFullName = fullName.trim().toUpperCase();
  for (var entry in bookCodeToFullName.entries) {
    if (entry.value.toUpperCase() == upperFullName) {
      return entry.key;
    }
  }
  // Fallback for common variations like "Psalms" vs "Psalm"
  if (upperFullName == "PSALM"){
    return "PSA";
  }
  // More sophisticated matching could be added here if needed
  print("Warning: Abbreviation not found for book name '$fullName'. Returning empty string.");
  return ""; // Return empty or a placeholder if not found
}
