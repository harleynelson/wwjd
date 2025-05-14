// lib/database_helper.dart
import 'dart:io';
import 'dart:math';
import 'dart:convert'; 
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/models.dart'; 
import 'reading_plans_data.dart'; 

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String dbName = "wwjd_bible_free.sqlite";
  static const int _dbVersion = 3; 

  // Table and Column constants (ensure all are defined as before)
  static const String bibleTableName = "engfbv_vpl";
  static const String bibleColBook = "book";
  static const String bibleColCanonOrder = "canon_order"; 
  static const String bibleColChapter = "chapter";
  static const String bibleColStartVerse = "startVerse";
  static const String bibleColVerseText = "verseText";
  static const String bibleColVerseID = "verseID"; 

  static const String favTableName = "favorites";
  static const String favColVerseID = "verseID"; 
  static const String favColBookAbbr = "book_abbr";
  static const String favColChapter = "chapter";
  static const String favColVerseNumber = "verse_number";
  static const String favColVerseText = "verse_text";
  static const String favColCreatedAt = "created_at";

  static const String flagsTableName = "user_flags";
  static const String flagsColId = "flag_id"; 
  static const String flagsColName = "flag_name"; 

  static const String favFlagsTableName = "favorite_flags";
  static const String favFlagsColFavVerseID = "favorite_verseID"; 
  static const String favFlagsColFlagID = "flag_id";          

  static const String progressTableName = "user_reading_progress";
  static const String progressColPlanId = "plan_id"; 
  static const String progressColCurrentDay = "current_day"; 
  static const String progressColCompletedDaysJson = "completed_days_json"; 
  static const String progressColStartDate = "start_date"; 
  static const String progressColLastCompletionDate = "last_completion_date"; 
  static const String progressColStreakCount = "streak_count"; 
  static const String progressColIsActive = "is_active"; 


  static String encodeJson(Map<dynamic, dynamic> map) {
    return json.encode(map);
  }

  static Map<String, dynamic> decodeJson(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      print("Error decoding JSON: $jsonString, Error: $e");
      return {}; 
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // ... (initDatabase logic as before)
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
        rethrow; 
      }
    } else {
      print("Opening existing database at $path.");
    }
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreateDB, onUpgrade: _onUpgradeDB);
  }

  Future<void> _onCreateDB(Database db, int version) async {
    // ... (_onCreateDB logic as before, ensuring all tables are created IF NOT EXISTS)
    print("onCreateDB: Creating app-specific tables for version $version...");
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $favTableName (
        $favColVerseID TEXT PRIMARY KEY, $favColBookAbbr TEXT NOT NULL, $favColChapter TEXT NOT NULL,
        $favColVerseNumber TEXT NOT NULL, $favColVerseText TEXT NOT NULL, $favColCreatedAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $flagsTableName (
        $flagsColId INTEGER PRIMARY KEY AUTOINCREMENT, $flagsColName TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $favFlagsTableName (
        $favFlagsColFavVerseID TEXT NOT NULL, $favFlagsColFlagID INTEGER NOT NULL,
        PRIMARY KEY ($favFlagsColFavVerseID, $favFlagsColFlagID),
        FOREIGN KEY ($favFlagsColFavVerseID) REFERENCES $favTableName ($favColVerseID) ON DELETE CASCADE
      )
    ''');
    await _createProgressTable(db);
    print("All app-specific tables processed in _onCreateDB.");
  }

  Future<void> _createProgressTable(Database db) async {
    // ... (_createProgressTable logic as before)
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
    // ... (_onUpgradeDB logic as before)
    print("onUpgradeDB: Upgrading database from version $oldVersion to $newVersion...");
    if (oldVersion < 2) {
      await db.execute('CREATE TABLE IF NOT EXISTS $favTableName ($favColVerseID TEXT PRIMARY KEY, $favColBookAbbr TEXT NOT NULL, $favColChapter TEXT NOT NULL, $favColVerseNumber TEXT NOT NULL, $favColVerseText TEXT NOT NULL, $favColCreatedAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS $flagsTableName ($flagsColId INTEGER PRIMARY KEY AUTOINCREMENT, $flagsColName TEXT NOT NULL UNIQUE)');
      await db.execute('CREATE TABLE IF NOT EXISTS $favFlagsTableName ($favFlagsColFavVerseID TEXT NOT NULL, $favFlagsColFlagID INTEGER NOT NULL, PRIMARY KEY ($favFlagsColFavVerseID, $favFlagsColFlagID), FOREIGN KEY ($favFlagsColFavVerseID) REFERENCES $favTableName ($favColVerseID) ON DELETE CASCADE)');
      print("Ensured tables for v2 exist during upgrade.");
    }
    if (oldVersion < 3) {
      await _createProgressTable(db);
      print("Upgraded database to version 3: Added $progressTableName table.");
    }
  }

  // --- Bible Data Methods ---
  // ... (getBookAbbreviations, getChaptersForBook, getVersesForChapter, getVerseOfTheDay, getVersesForPassage - keep as before)
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
    return await db.query( bibleTableName, columns: [bibleColStartVerse, bibleColVerseText, bibleColVerseID, bibleColBook, bibleColChapter], where: '$bibleColBook = ? AND $bibleColChapter = ?', whereArgs: [bookAbbreviation, chapterNumber], orderBy: 'CAST($bibleColStartVerse AS INTEGER)',);
  }
  Future<Map<String, dynamic>?> getVerseOfTheDay() async {
    final db = await database;
    int? count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT($bibleColVerseID) FROM $bibleTableName'));
    if (count != null && count > 0) {
      int randomOffset = Random().nextInt(count);
      final List<Map<String, dynamic>> result = await db.query(bibleTableName, columns: [bibleColBook, bibleColChapter, bibleColStartVerse, bibleColVerseText, bibleColVerseID], limit: 1, offset: randomOffset,);
      if (result.isNotEmpty) { return result.first; }
    }
    return null;
  }
   Future<List<Verse>> getVersesForPassage(BiblePassagePointer passage) async {
    final db = await database;
    List<Map<String, dynamic>> maps = [];
    if (passage.startChapter == passage.endChapter) {
      maps = await db.query( bibleTableName, columns: [bibleColStartVerse, bibleColVerseText, bibleColVerseID, bibleColBook, bibleColChapter], where: '$bibleColBook = ? AND $bibleColChapter = ? AND CAST($bibleColStartVerse AS INTEGER) >= ? AND CAST($bibleColStartVerse AS INTEGER) <= ?', whereArgs: [passage.bookAbbr, passage.startChapter, passage.startVerse, passage.endVerse], orderBy: 'CAST($bibleColStartVerse AS INTEGER) ASC',);
    } else {
      print("WARNING: getVersesForPassage currently best supports single-chapter passages. Requested: ${passage.displayText}");
       maps = await db.query( bibleTableName, columns: [bibleColStartVerse, bibleColVerseText, bibleColVerseID, bibleColBook, bibleColChapter], where: '$bibleColBook = ? AND $bibleColChapter = ? AND CAST($bibleColStartVerse AS INTEGER) >= ?', whereArgs: [passage.bookAbbr, passage.startChapter, passage.startVerse], orderBy: 'CAST($bibleColStartVerse AS INTEGER) ASC',);
    }
    return maps.map((map) => Verse( verseID: map[bibleColVerseID] as String?, bookAbbr: map[bibleColBook] as String?, chapter: map[bibleColChapter]?.toString(), verseNumber: map[bibleColStartVerse].toString(), text: map[bibleColVerseText] as String,)).toList();
  }

  // --- Favorites Methods ---
  // ... (addFavorite, removeFavorite, isFavorite, getFavoritedVerses, getFavoritedVersesFilteredByFlag - keep as before)
  Future<void> addFavorite(Map<String, dynamic> verseData) async {
    final db = await database;
    await db.insert(favTableName, {favColVerseID: verseData[bibleColVerseID], favColBookAbbr: verseData[bibleColBook], favColChapter: verseData[bibleColChapter].toString(), favColVerseNumber: verseData[bibleColStartVerse].toString(), favColVerseText: verseData[bibleColVerseText], favColCreatedAt: DateTime.now().toIso8601String(),}, conflictAlgorithm: ConflictAlgorithm.replace,);
  }
  Future<void> removeFavorite(String verseID) async {
     final db = await database;
    await db.delete( favTableName, where: '$favColVerseID = ?', whereArgs: [verseID],);
    await db.delete( favFlagsTableName, where: '$favFlagsColFavVerseID = ?', whereArgs: [verseID],);
  }
  Future<bool> isFavorite(String verseID) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(favTableName, where: '$favColVerseID = ?', whereArgs: [verseID], limit: 1,);
    return maps.isNotEmpty;
  }
  Future<List<Map<String, dynamic>>> getFavoritedVerses() async {
    final db = await database;
    return await db.query(favTableName, orderBy: '$favColCreatedAt DESC');
  }
   Future<List<Map<String, dynamic>>> getFavoritedVersesFilteredByFlag(int flagId) async {
    final db = await database;
    final String query = ''' SELECT T1.* FROM $favTableName T1 INNER JOIN $favFlagsTableName T2 ON T1.$favColVerseID = T2.$favFlagsColFavVerseID WHERE T2.$favFlagsColFlagID = ? ORDER BY T1.$favColCreatedAt DESC ''';
    return await db.rawQuery(query, [flagId]);
  }

  // --- User Flag Methods ---
  // ... (addUserFlag, getUserFlags, deleteUserFlag - keep as before)
  Future<int> addUserFlag(String flagName) async {
     final db = await database;
    try {
       return await db.insert(flagsTableName, {flagsColName: flagName}, conflictAlgorithm: ConflictAlgorithm.ignore,);
    } catch (e) {
        print("Error adding user flag '$flagName' (maybe duplicate?): $e");
         final List<Map<String, dynamic>> existing = await db.query( flagsTableName, columns: [flagsColId], where: '$flagsColName = ?', whereArgs: [flagName], limit: 1);
         if (existing.isNotEmpty) return existing.first[flagsColId] as int;
        return -1;
    }
  }
  Future<List<Map<String, dynamic>>> getUserFlags() async {
      final db = await database;
    return await db.query(flagsTableName, orderBy: '$flagsColName ASC');
  }
  Future<void> deleteUserFlag(int flagId) async {
    if (flagId < 0) { print("Cannot delete pre-built flag with ID: $flagId from user flags table."); return; }
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(favFlagsTableName, where: '$favFlagsColFlagID = ?', whereArgs: [flagId]);
      await txn.delete(flagsTableName, where: '$flagsColId = ?', whereArgs: [flagId]);
    });
    print("Deleted user flag with ID: $flagId and its associations.");
  }

  // --- Favorite_Flag Junction Methods ---
  // ... (assignFlagToFavorite, removeFlagFromFavorite, getFlagIdsForFavorite - keep as before)
  Future<void> assignFlagToFavorite(String verseID, int flagId) async {
     final db = await database;
    await db.insert( favFlagsTableName, {favFlagsColFavVerseID: verseID, favFlagsColFlagID: flagId}, conflictAlgorithm: ConflictAlgorithm.ignore,);
  }
  Future<void> removeFlagFromFavorite(String verseID, int flagId) async {
    final db = await database;
    await db.delete( favFlagsTableName, where: '$favFlagsColFavVerseID = ? AND $favFlagsColFlagID = ?', whereArgs: [verseID, flagId],);
  }
  Future<List<int>> getFlagIdsForFavorite(String verseID) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(favFlagsTableName, columns: [favFlagsColFlagID], where: '$favFlagsColFavVerseID = ?', whereArgs: [verseID]);
    return maps.map((map) => map[favFlagsColFlagID] as int).toList();
  }

  // --- Book Order Method ---
  // ... (getBookAbbrToOrderMap - keep as before)
  Future<Map<String, String>> getBookAbbrToOrderMap() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT DISTINCT $bibleColBook, MIN($bibleColCanonOrder) as c_order FROM $bibleTableName GROUP BY $bibleColBook');
    Map<String, String> bookOrderMap = {};
    for (var map in maps) {
      String? bookAbbr = map[bibleColBook] as String?; String? canonOrder = map['c_order'] as String?;
      if (bookAbbr != null && canonOrder != null) { bookOrderMap[bookAbbr] = canonOrder; }
    }
    return bookOrderMap;
  }

  // --- Search Verses Method ---
  // ... (searchVerses - keep as before)
  Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    if (query.trim().isEmpty) { return []; }
    final db = await database;
    final String searchQuery = '%${query.trim()}%'; 
    final List<Map<String, dynamic>> maps = await db.query( bibleTableName, columns: [bibleColVerseID, bibleColBook, bibleColChapter, bibleColStartVerse, bibleColVerseText, bibleColCanonOrder], where: '$bibleColVerseText LIKE ?', whereArgs: [searchQuery], orderBy: '$bibleColCanonOrder ASC, CAST($bibleColChapter AS INTEGER) ASC, CAST($bibleColStartVerse AS INTEGER) ASC', limit: 100 );
    return maps;
  }

  // --- Reading Plan Progress Methods ---
  Future<void> saveReadingPlanProgress(UserReadingProgress progress) async { /* ... keep as before ... */ 
    final db = await database;
    await db.insert( progressTableName, progress.toMap(), conflictAlgorithm: ConflictAlgorithm.replace, );
  }
  Future<UserReadingProgress?> getReadingPlanProgress(String planId) async { /* ... keep as before ... */ 
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query( progressTableName, where: '$progressColPlanId = ?', whereArgs: [planId], limit: 1,);
    if (maps.isNotEmpty) { return UserReadingProgress.fromMap(maps.first); }
    return null;
  }
  Future<List<UserReadingProgress>> getAllReadingPlanProgresses() async { /* ... keep as before ... */ 
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(progressTableName);
    return maps.map((map) => UserReadingProgress.fromMap(map)).toList();
  }
  Future<List<UserReadingProgress>> getActiveReadingPlanProgresses() async { /* ... keep as before ... */ 
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query( progressTableName, where: '$progressColIsActive = ?', whereArgs: [1]);
    return maps.map((map) => UserReadingProgress.fromMap(map)).toList();
  }
  Future<void> markReadingDayAsComplete(String planId, int dayNumberToComplete) async { 
    final db = await database;
    UserReadingProgress? progress = await getReadingPlanProgress(planId);
    if (progress == null) { 
      print("Error: Could not find progress for planId $planId to mark day $dayNumberToComplete complete.");
      // Optionally, create a new progress entry if it's truly missing and should exist
      // For now, we'll just return if no progress is found.
      return; 
    }
    DateTime now = DateTime.now(); 
    DateTime todayDateOnly = DateTime(now.year, now.month, now.day);
    
    progress.completedDays[dayNumberToComplete] = now;
    
    // Ensure currentDayNumber advances correctly
    if (dayNumberToComplete >= progress.currentDayNumber) { 
      progress.currentDayNumber = dayNumberToComplete + 1; 
    }
    
    // Streak logic (remains the same)
    if (progress.lastCompletionDate != null) {
      DateTime lastCompletedDateOnly = DateTime( progress.lastCompletionDate!.year, progress.lastCompletionDate!.month, progress.lastCompletionDate!.day);
      int differenceInDays = todayDateOnly.difference(lastCompletedDateOnly).inDays;
      if (differenceInDays == 1) { 
        progress.streakCount++; 
      } else if (differenceInDays > 1) { 
        progress.streakCount = 1; // Reset streak if more than one day missed
      } else if (differenceInDays == 0 && progress.streakCount == 0) {
        // If completing another day on the same day and streak was 0, start streak at 1
        progress.streakCount = 1;
      }
      // If differenceInDays is 0 and streakCount > 0, streak remains unchanged for multiple completions on the same day.
    } else { 
      // First ever completion for this plan progress
      progress.streakCount = 1; 
    }
    progress.lastCompletionDate = now; 

    // REMOVED the check that used allReadingPlans:
    // try {
    //     final planDefinition = allReadingPlans.firstWhere((p) => p.id == planId); 
    //     if (progress.completedDays.length >= planDefinition.durationDays) { 
    //         print("Congratulations! Plan '$planId' fully completed."); 
    //     }
    // } catch (e) { 
    //     print("Could not find plan definition for $planId to check for completion: $e"); 
    // }
    // The UI or ReadingPlanService can now be responsible for checking if 
    // progress.completedDays.length >= plan.durationDays (where plan is the loaded ReadingPlan object)

    await saveReadingPlanProgress(progress);
    print("Marked day $dayNumberToComplete for plan $planId as complete. Streak: ${progress.streakCount}. Current Day: ${progress.currentDayNumber}");
  }

  Future<void> setPlanActivity(String planId, bool isActive) async { /* ... keep as before ... */ 
    UserReadingProgress? progress = await getReadingPlanProgress(planId);
    if (progress != null) { progress.isActive = isActive; await saveReadingPlanProgress(progress); }
  }
  Future<void> deleteReadingPlanProgress(String planId) async { /* ... keep as before ... */ 
    final db = await database;
    await db.delete( progressTableName, where: '$progressColPlanId = ?', whereArgs: [planId],);
  }

  // --- MODIFIED: Method to reset all reading plan streaks AND progress ---
  Future<void> resetAllStreaksAndProgress() async {
    final db = await database;
    int count = await db.update(
      progressTableName,
      {
        progressColStreakCount: 0,
        progressColLastCompletionDate: null,
        progressColCurrentDay: 1, // Reset to Day 1
        progressColCompletedDaysJson: encodeJson({}), // Clear completed days map
        progressColIsActive: 1, // Mark as active to allow restart
        progressColStartDate: DateTime.now().toIso8601String(), // Optionally reset start date
      },
      // No 'where' clause, so it updates all rows
    );
    print("Reset streaks and progress for $count reading plan entries.");
  }
  // --- END MODIFICATION ---
}
