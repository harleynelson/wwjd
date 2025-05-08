// lib/search_screen.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models.dart'; // Imports Verse, Book, etc. (Though only Verse properties used directly here)
import 'book_names.dart'; // Imports getFullBookName
import 'full_bible_reader_screen.dart'; // Imports the target screen for navigation

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = []; // Store raw DB results
  bool _isLoading = false;
  bool _hasSearched = false; // Track if a search has been performed
  String _currentQuery = ""; // Store query for highlighting

  // Note: We are not currently loading favorite/flag status for search results
  // To do so would require more complex loading or data passing.

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Performs the database search
  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    final trimmedQuery = query.trim();
    // Store the actual query used, for highlighting
    _currentQuery = trimmedQuery;

    // If query is empty, clear results and mark as searched
    if (trimmedQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _hasSearched = true; // Indicate that an "empty" search was done
      });
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
      _hasSearched = true; // Mark that a search attempt is happening
    });

    try {
      // Call the database helper method
      final results = await _dbHelper.searchVerses(trimmedQuery);
      // Update state with results if widget is still mounted
       if (mounted) {
         setState(() {
           _searchResults = results;
           _isLoading = false;
         });
       }
    } catch (e) {
      print("Error performing search: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = []; // Clear results on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error during search: ${e.toString()}"))
        );
      }
    }
  }

  // Helper function to highlight search terms in the result text
  // Returns an InlineSpan for use with RichText
  InlineSpan _highlightText(String source, String query, BuildContext context) {
    // Use default text style from theme for good contrast
    final TextStyle baseStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final TextStyle highlightStyle = baseStyle.copyWith(
        backgroundColor: Colors.yellow.shade200, // Softer yellow highlight
        fontWeight: FontWeight.bold,
        color: Colors.black87 // Ensure text on yellow is readable
      );

    // Return original text if query is empty or not found (case-insensitive)
    if (query.isEmpty || !source.toLowerCase().contains(query.toLowerCase())) {
      return TextSpan(text: source, style: baseStyle);
    }

    final List<TextSpan> spans = [];
    final String lowerSource = source.toLowerCase();
    final String lowerQuery = query.toLowerCase();

    int startIndex = 0;
    int index = lowerSource.indexOf(lowerQuery);

    while (index != -1) {
      // Add text segment before the match (if any)
      if (index > startIndex) {
        spans.add(TextSpan(text: source.substring(startIndex, index), style: baseStyle));
      }
      // Add the highlighted match segment
      spans.add(TextSpan(
        text: source.substring(index, index + query.length),
        style: highlightStyle,
      ));
      // Update startIndex for the next search segment
      startIndex = index + query.length;
      // Find the next occurrence of the query
      index = lowerSource.indexOf(lowerQuery, startIndex);
    }

    // Add any remaining text after the last match
    if (startIndex < source.length) {
      spans.add(TextSpan(text: source.substring(startIndex), style: baseStyle));
    }

    // Return a single TextSpan containing all segments
    return TextSpan(children: spans);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Bible"),
      ),
      body: Column(
        children: [
          // --- Search Input Field ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // Add bottom padding
            child: TextField(
              controller: _searchController,
              autofocus: true, // Focus the field automatically
              decoration: InputDecoration(
                hintText: 'Enter keyword or phrase...',
                labelText: 'Search Term',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                // Clear button
                suffixIcon: _searchController.text.isNotEmpty
                 ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: "Clear Search",
                      onPressed: () {
                        _searchController.clear();
                        _performSearch(''); // Clear results when text is cleared
                      },
                    )
                 : null, // No clear button if field is empty
              ),
              textInputAction: TextInputAction.search, // Show search action on keyboard
              onSubmitted: _performSearch, // Search when keyboard action is pressed
              onChanged: (value) {
                 // Update clear button visibility live
                 setState(() {});
                 // Optional: Could trigger search here with debounce if desired
              },
            ),
          ),

          // --- Search Results Area ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                // Show message only if a search was attempted (prevents initial message)
                : !_hasSearched
                    ? const Center(child: Text("Enter text above to search.", style: TextStyle(fontSize: 16, color: Colors.grey)))
                    // Show message if search attempted but no results
                    : _searchResults.isEmpty
                        ? Center(child: Text("No results found for '$_currentQuery'.", style: const TextStyle(fontSize: 16, color: Colors.grey)))
                        // Display results in a ListView
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              // Safely extract data for reference display
                              final String bookAbbr = result[DatabaseHelper.bibleColBook] ?? '??';
                              final String chapter = result[DatabaseHelper.bibleColChapter]?.toString() ?? '?';
                              final String verseNum = result[DatabaseHelper.bibleColStartVerse]?.toString() ?? '?';
                              final String verseText = result[DatabaseHelper.bibleColVerseText] ?? '';
                              final String reference = "${getFullBookName(bookAbbr)} $chapter:$verseNum";

                              // Display each result in a ListTile
                              return ListTile(
                                dense: true,
                                title: Text(reference, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: RichText( // Use RichText for highlighting
                                  text: _highlightText(verseText, _currentQuery, context),
                                ),
                                // --- onTap Navigation ---
                                onTap: () {
                                  // Extract target details for navigation
                                  final String? targetBook = result[DatabaseHelper.bibleColBook];
                                  final String? targetChapter = result[DatabaseHelper.bibleColChapter]?.toString();
                                  final String? targetVerse = result[DatabaseHelper.bibleColStartVerse]?.toString();

                                  // Navigate only if all parts are valid
                                  if (targetBook != null && targetChapter != null && targetVerse != null) {
                                    print("Navigating to: $targetBook $targetChapter:$targetVerse");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullBibleReaderScreen(
                                          targetBookAbbr: targetBook,
                                          targetChapter: targetChapter,
                                          targetVerseNumber: targetVerse,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Could not determine verse location."))
                                    );
                                  }
                                }, // --- End onTap ---
                              ); // End ListTile
                            }, // End itemBuilder
                          ), // End ListView.builder
          ), // End Expanded Results Area
        ],
      ),
    );
  }
}