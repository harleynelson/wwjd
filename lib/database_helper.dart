// lib/database_helper.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // --- Keep existing code from previous version ---
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String dbName = "wwjd_bible_free.sqlite";
  static const int _dbVersion = 2;

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

  static const String flagsTableName = "user_flags"; // User flags ONLY
  static const String flagsColId = "flag_id";
  static const String flagsColName = "flag_name";

  static const String favFlagsTableName = "favorite_flags";
  static const String favFlagsColFavVerseID = "favorite_verseID";
  static const String favFlagsColFlagID = "flag_id";

  Future<Database> get database async { /* ... same as before ... */
     if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase() async { /* ... same as before ... */
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
        print("Database copied.");
        return await openDatabase(path, version: _dbVersion, onCreate: _onCreateDB);
      } catch (e) {
        print("Error copying database: $e");
        rethrow;
      }
    } else {
      print("Opening existing database.");
      return await openDatabase(path, version: _dbVersion, onCreate: _onCreateDB, onUpgrade: _onUpgradeDB);
    }
  }
  Future<void> _onCreateDB(Database db, int version) async { /* ... same as before ... */
    print("onCreateDB: Creating tables for version $version...");
    await db.execute(/* favTableName SQL */'''
      CREATE TABLE $favTableName (
        $favColVerseID TEXT PRIMARY KEY, $favColBookAbbr TEXT NOT NULL, $favColChapter TEXT NOT NULL,
        $favColVerseNumber TEXT NOT NULL, $favColVerseText TEXT NOT NULL, $favColCreatedAt TEXT NOT NULL
      )
    ''');
    await db.execute(/* flagsTableName SQL */'''
      CREATE TABLE $flagsTableName (
        $flagsColId INTEGER PRIMARY KEY AUTOINCREMENT, $flagsColName TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute(/* favFlagsTableName SQL */'''
      CREATE TABLE $favFlagsTableName (
        $favFlagsColFavVerseID TEXT NOT NULL, $favFlagsColFlagID INTEGER NOT NULL,
        PRIMARY KEY ($favFlagsColFavVerseID, $favFlagsColFlagID),
        FOREIGN KEY ($favFlagsColFavVerseID) REFERENCES $favTableName ($favColVerseID) ON DELETE CASCADE
      )
    ''');
     print("Tables created.");
  }
  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async { /* ... same as before ... */
     print("onUpgradeDB: Upgrading from $oldVersion to $newVersion...");
    if (oldVersion < 2) {
       await db.execute('CREATE TABLE IF NOT EXISTS $favTableName (...)'); // Use full schema
       await db.execute('CREATE TABLE IF NOT EXISTS $flagsTableName (...)'); // Use full schema
       await db.execute('CREATE TABLE IF NOT EXISTS $favFlagsTableName (...)'); // Use full schema
       print("Ensured tables exist during upgrade to v2.");
    }
  }

  // --- Bible Data Methods (Unchanged) ---
  Future<List<Map<String, dynamic>>> getBookAbbreviations() async { /* ... same as before ... */
    final db = await database;
    return await db.rawQuery('SELECT DISTINCT $bibleColBook, MIN($bibleColCanonOrder) as c_order FROM $bibleTableName GROUP BY $bibleColBook ORDER BY c_order');
  }
  Future<List<String>> getChaptersForBook(String bookAbbreviation) async { /* ... same as before ... */
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT DISTINCT $bibleColChapter FROM $bibleTableName WHERE $bibleColBook = ? ORDER BY CAST($bibleColChapter AS INTEGER)', [bookAbbreviation]);
    return maps.map((map) => map[bibleColChapter].toString()).toList();
  }
  Future<List<Map<String, dynamic>>> getVersesForChapter(String bookAbbreviation, String chapterNumber) async { /* ... same as before ... */
      final db = await database;
      return await db.query(bibleTableName, columns: [bibleColStartVerse, bibleColVerseText, bibleColVerseID, bibleColBook, bibleColChapter], where: '$bibleColBook = ? AND $bibleColChapter = ?', whereArgs: [bookAbbreviation, chapterNumber], orderBy: 'CAST($bibleColStartVerse AS INTEGER)',);
  }
  Future<Map<String, dynamic>?> getVerseOfTheDay() async { /* ... same as before ... */
    final db = await database;
    int? count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT($bibleColVerseID) FROM $bibleTableName'));
    if (count != null && count > 0) {
      int randomOffset = Random().nextInt(count);
      final List<Map<String, dynamic>> result = await db.query(bibleTableName, columns: [bibleColBook, bibleColChapter, bibleColStartVerse, bibleColVerseText, bibleColVerseID], limit: 1, offset: randomOffset,);
      if (result.isNotEmpty) { return result.first; }
    }
    return null;
  }

  // --- Favorites Methods (Unchanged) ---
  Future<void> addFavorite(Map<String, dynamic> verseData) async { /* ... same as before ... */
    final db = await database;
    await db.insert(favTableName, {favColVerseID: verseData[bibleColVerseID], favColBookAbbr: verseData[bibleColBook], favColChapter: verseData[bibleColChapter].toString(), favColVerseNumber: verseData[bibleColStartVerse].toString(), favColVerseText: verseData[bibleColVerseText], favColCreatedAt: DateTime.now().toIso8601String(),}, conflictAlgorithm: ConflictAlgorithm.replace,);
  }
  Future<void> removeFavorite(String verseID) async { /* ... same as before ... */
     final db = await database;
    await db.delete( favTableName, where: '$favColVerseID = ?', whereArgs: [verseID],);
    await db.delete( favFlagsTableName, where: '$favFlagsColFavVerseID = ?', whereArgs: [verseID],);
  }
  Future<bool> isFavorite(String verseID) async { /* ... same as before ... */
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(favTableName, where: '$favColVerseID = ?', whereArgs: [verseID], limit: 1,);
    return maps.isNotEmpty;
  }
  Future<List<Map<String, dynamic>>> getFavoritedVerses() async { /* ... same as before ... */
    final db = await database;
    return await db.query(favTableName, orderBy: '$favColCreatedAt DESC');
  }

  // --- User Flag Methods ---
  Future<int> addUserFlag(String flagName) async { /* ... same as before ... */
     final db = await database;
    try {
       return await db.insert(flagsTableName, {flagsColName: flagName}, conflictAlgorithm: ConflictAlgorithm.ignore,);
    } catch (e) {
        print("Error adding user flag (maybe duplicate?): $e");
         final List<Map<String, dynamic>> existing = await db.query( flagsTableName, columns: [flagsColId], where: '$flagsColName = ?', whereArgs: [flagName], limit: 1);
         if (existing.isNotEmpty) return existing.first[flagsColId] as int;
        return -1;
    }
  }
  Future<List<Map<String, dynamic>>> getUserFlags() async { /* ... same as before ... */
      final db = await database;
    return await db.query(flagsTableName, orderBy: '$flagsColName ASC');
  }

  // --- NEW: Method to delete a user-defined flag ---
  Future<void> deleteUserFlag(int flagId) async {
    // Important: Only delete user flags (positive IDs)
    if (flagId < 0) {
      print("Cannot delete pre-built flag with ID: $flagId");
      return;
    }
    final db = await database;
    await db.transaction((txn) async {
      // Delete assignments first from the junction table
      await txn.delete(favFlagsTableName, where: '$favFlagsColFlagID = ?', whereArgs: [flagId]);
      // Then delete the flag definition itself from the user flags table
      await txn.delete(flagsTableName, where: '$flagsColId = ?', whereArgs: [flagId]);
    });
    print("Deleted user flag with ID: $flagId");
  }


  // --- Favorite_Flag Junction Methods (Unchanged) ---
  Future<void> assignFlagToFavorite(String verseID, int flagId) async { /* ... same as before ... */
     final db = await database;
    await db.insert( favFlagsTableName, {favFlagsColFavVerseID: verseID, favFlagsColFlagID: flagId}, conflictAlgorithm: ConflictAlgorithm.ignore,);
  }
  Future<void> removeFlagFromFavorite(String verseID, int flagId) async { /* ... same as before ... */
    final db = await database;
    await db.delete( favFlagsTableName, where: '$favFlagsColFavVerseID = ? AND $favFlagsColFlagID = ?', whereArgs: [verseID, flagId],);
  }
  Future<List<int>> getFlagIdsForFavorite(String verseID) async { /* ... same as before ... */
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(favFlagsTableName, columns: [favFlagsColFlagID], where: '$favFlagsColFavVerseID = ?', whereArgs: [verseID]);
    return maps.map((map) => map[favFlagsColFlagID] as int).toList();
  }


  // MODIFIED: Return a Map<BookAbbr, CanonOrder> for easy lookup
  Future<Map<String, String>> getBookAbbrToOrderMap() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT $bibleColBook, MIN($bibleColCanonOrder) as c_order FROM $bibleTableName GROUP BY $bibleColBook');
    Map<String, String> bookOrderMap = {};
    for (var map in maps) {
      // Use null-aware operator for safety, though DB columns are NOT NULL
      String? bookAbbr = map[bibleColBook] as String?;
      String? canonOrder = map['c_order'] as String?;
      if (bookAbbr != null && canonOrder != null) {
          bookOrderMap[bookAbbr] = canonOrder;
      }
    }
    return bookOrderMap;
  }

  // NEW: GET FAVORITES FILTERED BY FLAG
  Future<List<Map<String, dynamic>>> getFavoritedVersesFilteredByFlag(int flagId) async {
    final db = await database;
    // Join favorites with the junction table, filter by flagId
    final String query = '''
      SELECT T1.*
      FROM $favTableName T1
      INNER JOIN $favFlagsTableName T2 ON T1.$favColVerseID = T2.$favFlagsColFavVerseID
      WHERE T2.$favFlagsColFlagID = ?
      ORDER BY T1.$favColCreatedAt DESC
    ''';
    // Note: JOIN might affect performance on very large tables if not indexed correctly.
    // An alternative is separate queries, filtering in Dart, but JOIN is often better.
    return await db.rawQuery(query, [flagId]);
  }

  /// Searches for verses containing the given query text.
  /// Returns a list of maps, each representing a verse.
  /// Uses basic LIKE search (case-insensitive for ASCII).
  /// Consider SQLite FTS5 for better performance on large datasets later.
  Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    if (query.trim().isEmpty) {
      return []; // Return empty list if query is empty or whitespace
    }
    final db = await database;
    // Use '%' wildcards for contains search
    final String searchQuery = '%${query.trim()}%';

    // Query the bible table where verseText contains the query
    // Fetch all necessary columns to display the result context
    // Order by canon_order to show results in Bible order
    final List<Map<String, dynamic>> maps = await db.query(
      bibleTableName,
      columns: [
        bibleColVerseID,
        bibleColBook,
        bibleColChapter,
        bibleColStartVerse,
        bibleColVerseText,
        bibleColCanonOrder // Include for reliable sorting
      ],
      where: '$bibleColVerseText LIKE ?',
      whereArgs: [searchQuery],
      orderBy: '$bibleColCanonOrder ASC, CAST($bibleColChapter AS INTEGER) ASC, CAST($bibleColStartVerse AS INTEGER) ASC',
      limit: 100 // Limit results for performance initially, can add pagination later
    );
    print("Search for '$query' found ${maps.length} results.");
    return maps;
  }
}