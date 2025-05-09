// lib/database_helper.dart
import 'dart:io';
import 'dart:math';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart'; // Ensure UserReadingProgress is defined here
import 'reading_plans_data.dart'; // Required for markReadingDayAsComplete to access plan details

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String dbName = "wwjd_bible_free.sqlite";
  static const int _dbVersion = 3; // Incremented for the new table

  // Bible Table (VPL)
  static const String bibleTableName = "engfbv_vpl";
  static const String bibleColBook = "book";
  static const String bibleColCanonOrder = "canon_order"; // Assuming this column exists in your VPL for sorting
  static const String bibleColChapter = "chapter";
  static const String bibleColStartVerse = "startVerse";
  static const String bibleColVerseText = "verseText";
  static const String bibleColVerseID = "verseID"; // Assuming this is unique identifier for verses

  // Favorites Table
  static const String favTableName = "favorites";
  static const String favColVerseID = "verseID"; // Foreign Key to bibleColVerseID
  static const String favColBookAbbr = "book_abbr";
  static const String favColChapter = "chapter";
  static const String favColVerseNumber = "verse_number";
  static const String favColVerseText = "verse_text";
  static const String favColCreatedAt = "created_at";

  // User Flags Table
  static const String flagsTableName = "user_flags";
  static const String flagsColId = "flag_id"; // INTEGER PRIMARY KEY AUTOINCREMENT
  static const String flagsColName = "flag_name"; // TEXT UNIQUE

  // Favorite-Flags Junction Table
  static const String favFlagsTableName = "favorite_flags";
  static const String favFlagsColFavVerseID = "favorite_verseID"; // Foreign Key to favColVerseID
  static const String favFlagsColFlagID = "flag_id";          // Foreign Key to flagsColId or pre-built ID

  // New Table for User Reading Progress
  static const String progressTableName = "user_reading_progress";
  static const String progressColPlanId = "plan_id"; // TEXT, PRIMARY KEY
  static const String progressColCurrentDay = "current_day"; // INTEGER, next day to read
  static const String progressColCompletedDaysJson = "completed_days_json"; // TEXT (JSON map of dayNumber:completionDate)
  static const String progressColStartDate = "start_date"; // TEXT (ISO8601 string)
  static const String progressColLastCompletionDate = "last_completion_date"; // TEXT (ISO8601 string)
  static const String progressColStreakCount = "streak_count"; // INTEGER
  static const String progressColIsActive = "is_active"; // INTEGER (0 for false, 1 for true)

  // Helper methods for JSON encoding/decoding
  static String encodeJson(Map<dynamic, dynamic> map) {
    return json.encode(map);
  }

  static Map<String, dynamic> decodeJson(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      print("Error decoding JSON: $jsonString, Error: $e");
      return {}; // Return empty map on error
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    bool dbExists = await databaseExists(path);

    if (!dbExists) {
      print("Database does not exist. Copying from assets...");
      try {
        await Directory(dirname(path)).create(recursive: true);
        ByteData data = await rootBundle.load(join("assets/database", dbName));
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
        print("Database copied from assets.");
      } catch (e) {
        print("Error copying database from assets: $e");
        rethrow; // Rethrow to handle appropriately
      }
    } else {
      print("Opening existing database at $path.");
    }
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreateDB, onUpgrade: _onUpgradeDB);
  }

  Future<void> _onCreateDB(Database db, int version) async {
    print("onCreateDB: Creating app-specific tables for version $version...");
    // These tables are managed by the app, not assumed to be in the pre-loaded VPL asset.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $favTableName (
        $favColVerseID TEXT PRIMARY KEY,
        $favColBookAbbr TEXT NOT NULL,
        $favColChapter TEXT NOT NULL,
        $favColVerseNumber TEXT NOT NULL,
        $favColVerseText TEXT NOT NULL,
        $favColCreatedAt TEXT NOT NULL
      )
    ''');
    print("Table $favTableName created or already exists.");

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $flagsTableName (
        $flagsColId INTEGER PRIMARY KEY AUTOINCREMENT,
        $flagsColName TEXT NOT NULL UNIQUE
      )
    ''');
    print("Table $flagsTableName created or already exists.");

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $favFlagsTableName (
        $favFlagsColFavVerseID TEXT NOT NULL,
        $favFlagsColFlagID INTEGER NOT NULL,
        PRIMARY KEY ($favFlagsColFavVerseID, $favFlagsColFlagID),
        FOREIGN KEY ($favFlagsColFavVerseID) REFERENCES $favTableName ($favColVerseID) ON DELETE CASCADE
      )
    ''');
    print("Table $favFlagsTableName created or already exists.");

    await _createProgressTable(db); // Create the new progress table
    print("All app-specific tables processed in _onCreateDB.");
  }

  Future<void> _createProgressTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $progressTableName (
        $progressColPlanId TEXT PRIMARY KEY,
        $progressColCurrentDay INTEGER NOT NULL DEFAULT 1,
        $progressColCompletedDaysJson TEXT,
        $progressColStartDate TEXT NOT NULL,
        $progressColLastCompletionDate TEXT,
        $progressColStreakCount INTEGER NOT NULL DEFAULT 0,
        $progressColIsActive INTEGER NOT NULL DEFAULT 1
      )
    ''');
    print("Table $progressTableName created or already exists.");
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    print("onUpgradeDB: Upgrading database from version $oldVersion to $newVersion...");
    if (oldVersion < 2) {
      // Version 2 added favorites, flags, and favorite_flags tables.
      // Using IF NOT EXISTS to be safe, as _onCreateDB also uses it.
      await db.execute('CREATE TABLE IF NOT EXISTS $favTableName ($favColVerseID TEXT PRIMARY KEY, $favColBookAbbr TEXT NOT NULL, $favColChapter TEXT NOT NULL, $favColVerseNumber TEXT NOT NULL, $favColVerseText TEXT NOT NULL, $favColCreatedAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS $flagsTableName ($flagsColId INTEGER PRIMARY KEY AUTOINCREMENT, $flagsColName TEXT NOT NULL UNIQUE)');
      await db.execute('CREATE TABLE IF NOT EXISTS $favFlagsTableName ($favFlagsColFavVerseID TEXT NOT NULL, $favFlagsColFlagID INTEGER NOT NULL, PRIMARY KEY ($favFlagsColFavVerseID, $favFlagsColFlagID), FOREIGN KEY ($favFlagsColFavVerseID) REFERENCES $favTableName ($favColVerseID) ON DELETE CASCADE)');
      print("Ensured tables for v2 exist during upgrade.");
    }
    if (oldVersion < 3) {
      // Version 3 adds the reading progress table.
      await _createProgressTable(db);
      print("Upgraded database to version 3: Added $progressTableName table.");
    }
    // Add further upgrade steps here for future versions (e.g., if oldVersion < 4)
  }

  // --- Bible Data Methods ---
  Future<List<Map<String, dynamic>>> getBookAbbreviations() async {
    final db = await database;
    return await db.rawQuery('SELECT DISTINCT $bibleColBook, MIN($bibleColCanonOrder) as c_order FROM $bibleTableName GROUP BY $bibleColBook ORDER BY c_order');
  }

  Future<List<String>> getChaptersForBook(String bookAbbreviation) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT DISTINCT $bibleColChapter FROM $bibleTableName WHERE $bibleColBook = ? ORDER BY CAST($bibleColChapter AS INTEGER)', [bookAbbreviation]);
    return maps.map((map) => map[bibleColChapter].toString()).toList();
  }

  Future<List<Map<String, dynamic>>> getVersesForChapter(String bookAbbreviation, String chapterNumber) async {
    final db = await database;
    return await db.query(
      bibleTableName,
      columns: [bibleColStartVerse, bibleColVerseText, bibleColVerseID, bibleColBook, bibleColChapter],
      where: '$bibleColBook = ? AND $bibleColChapter = ?',
      whereArgs: [bookAbbreviation, chapterNumber],
      orderBy: 'CAST($bibleColStartVerse AS INTEGER)',
    );
  }

  Future<Map<String, dynamic>?> getVerseOfTheDay() async {
    final db = await database;
    int? count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT($bibleColVerseID) FROM $bibleTableName'));
    if (count != null && count > 0) {
      int randomOffset = Random().nextInt(count);
      final List<Map<String, dynamic>> result = await db.query(
        bibleTableName,
        columns: [bibleColBook, bibleColChapter, bibleColStartVerse, bibleColVerseText, bibleColVerseID],
        limit: 1,
        offset: randomOffset,
      );
      if (result.isNotEmpty) {
        return result.first;
      }
    }
    return null;
  }

  // --- Favorites Methods ---
  Future<void> addFavorite(Map<String, dynamic> verseData) async {
    final db = await database;
    await db.insert(
      favTableName,
      {
        favColVerseID: verseData[bibleColVerseID],
        favColBookAbbr: verseData[bibleColBook],
        favColChapter: verseData[bibleColChapter].toString(),
        favColVerseNumber: verseData[bibleColStartVerse].toString(),
        favColVerseText: verseData[bibleColVerseText],
        favColCreatedAt: DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(String verseID) async {
    final db = await database;
    await db.delete(favTableName, where: '$favColVerseID = ?', whereArgs: [verseID]);
    await db.delete(favFlagsTableName, where: '$favFlagsColFavVerseID = ?', whereArgs: [verseID]); // Also remove flag associations
  }

  Future<bool> isFavorite(String verseID) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      favTableName,
      where: '$favColVerseID = ?',
      whereArgs: [verseID],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getFavoritedVerses() async {
    final db = await database;
    return await db.query(favTableName, orderBy: '$favColCreatedAt DESC');
  }

  Future<List<Map<String, dynamic>>> getFavoritedVersesFilteredByFlag(int flagId) async {
    final db = await database;
    final String query = '''
      SELECT T1.*
      FROM $favTableName T1
      INNER JOIN $favFlagsTableName T2 ON T1.$favColVerseID = T2.$favFlagsColFavVerseID
      WHERE T2.$favFlagsColFlagID = ?
      ORDER BY T1.$favColCreatedAt DESC
    ''';
    return await db.rawQuery(query, [flagId]);
  }

  // --- User Flag Methods ---
  Future<int> addUserFlag(String flagName) async {
    final db = await database;
    try {
      return await db.insert(
        flagsTableName,
        {flagsColName: flagName},
        conflictAlgorithm: ConflictAlgorithm.ignore, // Ignore if flag name already exists
      );
    } catch (e) {
      // This catch block might be redundant if ConflictAlgorithm.ignore is used,
      // but good for debugging or if specific handling for duplicates is needed.
      print("Error adding user flag '$flagName' (maybe duplicate?): $e");
      // If it was an ignore, and we need the ID of the existing one:
      final List<Map<String, dynamic>> existing = await db.query(
        flagsTableName,
        columns: [flagsColId],
        where: '$flagsColName = ?',
        whereArgs: [flagName],
        limit: 1,
      );
      if (existing.isNotEmpty) return existing.first[flagsColId] as int;
      return -1; // Should not happen if insert was successful or ignored
    }
  }

  Future<List<Map<String, dynamic>>> getUserFlags() async {
    final db = await database;
    return await db.query(flagsTableName, orderBy: '$flagsColName ASC');
  }

  Future<void> deleteUserFlag(int flagId) async {
    if (flagId < 0) { // Pre-built flags have negative IDs and are not in this table
      print("Cannot delete pre-built flag with ID: $flagId from user flags table.");
      return;
    }
    final db = await database;
    await db.transaction((txn) async {
      // First, delete associations in the junction table
      await txn.delete(favFlagsTableName, where: '$favFlagsColFlagID = ?', whereArgs: [flagId]);
      // Then, delete the flag itself
      await txn.delete(flagsTableName, where: '$flagsColId = ?', whereArgs: [flagId]);
    });
    print("Deleted user flag with ID: $flagId and its associations.");
  }

  // --- Favorite_Flag Junction Methods ---
  Future<void> assignFlagToFavorite(String verseID, int flagId) async {
    final db = await database;
    await db.insert(
      favFlagsTableName,
      {favFlagsColFavVerseID: verseID, favFlagsColFlagID: flagId},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Prevent duplicate associations
    );
  }

  Future<void> removeFlagFromFavorite(String verseID, int flagId) async {
    final db = await database;
    await db.delete(
      favFlagsTableName,
      where: '$favFlagsColFavVerseID = ? AND $favFlagsColFlagID = ?',
      whereArgs: [verseID, flagId],
    );
  }

  Future<List<int>> getFlagIdsForFavorite(String verseID) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      favFlagsTableName,
      columns: [favFlagsColFlagID],
      where: '$favFlagsColFavVerseID = ?',
      whereArgs: [verseID],
    );
    return maps.map((map) => map[favFlagsColFlagID] as int).toList();
  }

  // --- Book Order Method ---
  Future<Map<String, String>> getBookAbbrToOrderMap() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT $bibleColBook, MIN($bibleColCanonOrder) as c_order FROM $bibleTableName GROUP BY $bibleColBook');
    Map<String, String> bookOrderMap = {};
    for (var map in maps) {
      String? bookAbbr = map[bibleColBook] as String?;
      String? canonOrder = map['c_order'] as String?; // Alias used in query
      if (bookAbbr != null && canonOrder != null) {
        bookOrderMap[bookAbbr] = canonOrder;
      }
    }
    return bookOrderMap;
  }

  // --- Search Verses Method ---
  Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    final db = await database;
    final String searchQuery = '%${query.trim()}%'; // Wildcards for contains search

    final List<Map<String, dynamic>> maps = await db.query(
      bibleTableName,
      columns: [bibleColVerseID, bibleColBook, bibleColChapter, bibleColStartVerse, bibleColVerseText, bibleColCanonOrder],
      where: '$bibleColVerseText LIKE ?', // Case-insensitive for ASCII by default in SQLite LIKE
      whereArgs: [searchQuery],
      orderBy: '$bibleColCanonOrder ASC, CAST($bibleColChapter AS INTEGER) ASC, CAST($bibleColStartVerse AS INTEGER) ASC',
      limit: 100, // Limit results for performance; consider pagination for more
    );
    print("Search for '$query' found ${maps.length} results.");
    return maps;
  }

  // --- Reading Plan Progress Methods ---

  /// Saves or updates the progress for a given reading plan.
  Future<void> saveReadingPlanProgress(UserReadingProgress progress) async {
    final db = await database;
    await db.insert(
      progressTableName,
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // If planId exists, update it
    );
    print("Saved/Updated progress for reading plan: ${progress.planId}");
  }

  /// Retrieves the progress for a specific reading plan.
  Future<UserReadingProgress?> getReadingPlanProgress(String planId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      progressTableName,
      where: '$progressColPlanId = ?',
      whereArgs: [planId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return UserReadingProgress.fromMap(maps.first);
    }
    return null; // No progress found for this plan
  }

  /// Retrieves all reading plan progresses, e.g., to show active plans.
  Future<List<UserReadingProgress>> getAllReadingPlanProgresses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(progressTableName);
    return maps.map((map) => UserReadingProgress.fromMap(map)).toList();
  }

    /// Retrieves all *active* reading plan progresses.
  Future<List<UserReadingProgress>> getActiveReadingPlanProgresses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      progressTableName,
      where: '$progressColIsActive = ?',
      whereArgs: [1] // Filter for active plans
    );
    return maps.map((map) => UserReadingProgress.fromMap(map)).toList();
  }


  /// Marks a specific day of a reading plan as complete and updates streak.
  Future<void> markReadingDayAsComplete(String planId, int dayNumberToComplete) async {
    final db = await database;
    UserReadingProgress? progress = await getReadingPlanProgress(planId);

    if (progress == null) {
      print("Error: Cannot mark day $dayNumberToComplete complete. No progress found for plan $planId.");
      // Optionally, you could auto-start the plan here if desired, but explicit start is usually better.
      // For now, we assume a plan must be started before marking days complete.
      // If you want to auto-start:
      // progress = UserReadingProgress(planId: planId, startDate: DateTime.now(), currentDayNumber: 1);
      // print("Auto-starting plan $planId to mark day $dayNumberToComplete.");
      // If not auto-starting, then just return or throw an error:
      return;
    }

    DateTime now = DateTime.now();
    DateTime todayDateOnly = DateTime(now.year, now.month, now.day);

    // Mark the day as complete
    progress.completedDays[dayNumberToComplete] = now;

    // Update currentDayNumber if this completion moves the user forward linearly
    if (dayNumberToComplete >= progress.currentDayNumber) {
      progress.currentDayNumber = dayNumberToComplete + 1;
    }

    // Streak Logic
    if (progress.lastCompletionDate != null) {
      DateTime lastCompletedDateOnly = DateTime(
          progress.lastCompletionDate!.year,
          progress.lastCompletionDate!.month,
          progress.lastCompletionDate!.day);

      int differenceInDays = todayDateOnly.difference(lastCompletedDateOnly).inDays;

      if (differenceInDays == 1) {
        // Completed on the consecutive day
        progress.streakCount++;
      } else if (differenceInDays > 1) {
        // Streak broken (more than one day passed)
        progress.streakCount = 1; // Reset to 1 for today's completion
      } else if (differenceInDays == 0) {
        // Completed again on the same day, streak remains the same
        // (unless it's the very first day of the streak, handled below)
        if (progress.streakCount == 0) progress.streakCount = 1;
      } else {
        // Time traveler? Or date set back. Reset streak.
        progress.streakCount = 1;
      }
    } else {
      // This is the very first completion for this plan's progress tracking
      progress.streakCount = 1;
    }
    progress.lastCompletionDate = now; // Update the last completion date

    // Check if the plan is fully completed
    // This requires knowing the total days in the plan.
    // For robustness, this check might be better done in the UI layer after fetching the plan details.
    // However, if we import reading_plans_data.dart (which is a bit of a layer violation but simple for now):
    try {
        final planDefinition = allReadingPlans.firstWhere((p) => p.id == planId);
        if (progress.completedDays.length >= planDefinition.durationDays) {
            // progress.isActive = false; // Optionally deactivate plan upon completion
            print("Congratulations! Plan '$planId' fully completed.");
        }
    } catch (e) {
        print("Could not find plan definition for $planId to check for completion: $e");
    }


    await saveReadingPlanProgress(progress); // Save all changes
    print("Day $dayNumberToComplete for plan '$planId' marked complete. Current Streak: ${progress.streakCount}. Next day: ${progress.currentDayNumber}");
  }

  /// Sets a plan's active status.
  Future<void> setPlanActivity(String planId, bool isActive) async {
    UserReadingProgress? progress = await getReadingPlanProgress(planId);
    if (progress != null) {
      progress.isActive = isActive;
      await saveReadingPlanProgress(progress);
      print("Plan '$planId' active status set to: $isActive");
    } else {
      print("Error: Could not set active status for plan '$planId'. No progress found.");
    }
  }

  /// Deletes all progress for a specific reading plan (e.g., to restart).
  Future<void> deleteReadingPlanProgress(String planId) async {
    final db = await database;
    await db.delete(
      progressTableName,
      where: '$progressColPlanId = ?',
      whereArgs: [planId],
    );
    print("Deleted progress for plan '$planId'.");
  }

  /// Fetches verses for a given BiblePassagePointer.
  /// Handles passages that might span multiple verses within a single chapter.
  /// For simplicity, this initial version assumes startChapter == endChapter.
  /// Spanning multiple chapters would require more complex query logic (looping or UNIONs).
  Future<List<Verse>> getVersesForPassage(BiblePassagePointer passage) async {
    final db = await database;
    List<Map<String, dynamic>> maps = [];

    if (passage.startChapter == passage.endChapter) {
      maps = await db.query(
        bibleTableName,
        columns: [bibleColStartVerse, bibleColVerseText, bibleColVerseID, bibleColBook, bibleColChapter],
        where: '$bibleColBook = ? AND $bibleColChapter = ? AND CAST($bibleColStartVerse AS INTEGER) >= ? AND CAST($bibleColStartVerse AS INTEGER) <= ?',
        whereArgs: [passage.bookAbbr, passage.startChapter, passage.startVerse, passage.endVerse],
        orderBy: 'CAST($bibleColStartVerse AS INTEGER) ASC',
      );
    } else {
      // More complex logic for multi-chapter spans:
      // 1. Verses from startChapter, startVerse to end of chapter
      // 2. Verses from all full chapters in between (if any)
      // 3. Verses from endChapter, 1 to endVerse
      // This can be done with multiple queries and concatenating results.
      // For now, let's keep it simple and log a warning if a multi-chapter passage is requested by this basic method.
      print("WARNING: getVersesForPassage currently best supports single-chapter passages. Requested: ${passage.displayText}");
      // Fallback to just getting the first chapter's portion for simplicity in this example
       maps = await db.query(
        bibleTableName,
        columns: [bibleColStartVerse, bibleColVerseText, bibleColVerseID, bibleColBook, bibleColChapter],
        where: '$bibleColBook = ? AND $bibleColChapter = ? AND CAST($bibleColStartVerse AS INTEGER) >= ?',
        whereArgs: [passage.bookAbbr, passage.startChapter, passage.startVerse],
        orderBy: 'CAST($bibleColStartVerse AS INTEGER) ASC',
      );
      // Ideally, you'd implement the full multi-chapter logic here.
      // One way:
      // List<Map<String, dynamic>> results = [];
      // // Verses from start chapter
      // results.addAll(await db.query(bibleTableName, where: '$bibleColBook = ? AND $bibleColChapter = ? AND CAST($bibleColStartVerse AS INTEGER) >= ?', whereArgs: [passage.bookAbbr, passage.startChapter, passage.startVerse], orderBy: 'CAST($bibleColStartVerse AS INTEGER) ASC'));
      // // Verses from intermediate chapters
      // for (int i = passage.startChapter + 1; i < passage.endChapter; i++) {
      //   results.addAll(await db.query(bibleTableName, where: '$bibleColBook = ? AND $bibleColChapter = ?', whereArgs: [passage.bookAbbr, i], orderBy: 'CAST($bibleColStartVerse AS INTEGER) ASC'));
      // }
      // // Verses from end chapter
      // results.addAll(await db.query(bibleTableName, where: '$bibleColBook = ? AND $bibleColChapter = ? AND CAST($bibleColStartVerse AS INTEGER) <= ?', whereArgs: [passage.bookAbbr, passage.endChapter, passage.endVerse], orderBy: 'CAST($bibleColStartVerse AS INTEGER) ASC'));
      // maps = results;
      // This simplistic fallback for multi-chapter needs robust implementation.
    }

    return maps.map((map) => Verse(
      verseID: map[bibleColVerseID] as String?,
      bookAbbr: map[bibleColBook] as String?,
      chapter: map[bibleColChapter]?.toString(),
      verseNumber: map[bibleColStartVerse].toString(),
      text: map[bibleColVerseText] as String,
    )).toList();
  }
}