import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<Map<String, List<String>>> articleListData;
  final TextEditingController _textEditingController =
      TextEditingController(); // Add a text editing controller

  @override
  void initState() {
    super.initState();
    articleListData = loadArticleDataSimple();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _textEditingController,
          onChanged: (text) {
            setState(() {}); // Rebuild the widget when the text changes
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: () {
                _textEditingController
                    .clear(); // Clear the text when the icon is pressed
                setState(() {}); // Rebuild the widget when the text is cleared
              },
              icon: const Icon(Icons.clear),
            ),
            labelText: 'Artikel',
            hintText: 'Search...',
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, List<String>>>(
        future: articleListData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final data = snapshot.data!;
            final searchText = _textEditingController.text.toLowerCase();

            // Filter the articles based on search text
            final filteredData = Map.fromEntries(
              data.entries.map((entry) {
                final day = entry.key;
                final articles = entry.value;
                return MapEntry(
                  day,
                  articles
                      .where((article) =>
                          article.toLowerCase().contains(searchText))
                      .toList(),
                );
              }),
            );

            return ListView(
              children: filteredData.entries.expand((entry) {
                final day = entry.key;
                final articles = entry.value;
                return articles
                    .map((article) => ArticleCard(day: day, article: article));
              }).toList(),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController
        .dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }
}

Future<Map<String, List<String>>> loadArticleDataSimple() async {
  // Load the JSON file from the assets folder
  String jsonString = await rootBundle.loadString('assets/simple_plan.json');

  // Decode the JSON string
  Map<String, dynamic> jsonData = json.decode(jsonString);

  // Return the map directly
  return jsonData.map((key, value) => MapEntry(key, List<String>.from(value)));
}

class ArticleCard extends StatefulWidget {
  const ArticleCard({super.key, required this.day, required this.article});

  final String day;
  final String article;

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  String get day => widget.day;
  String get article => widget.article;
  bool _isStarred = false;
  bool _isRead = false;

  @override
  void initState() {
    super.initState();
    _loadStarredStatus();
    _loadReadStatus();
  }

  void _loadStarredStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isStarred = prefs.getBool('starred_$article') ?? false;
    });
  }

  void _toggleStarred() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isStarred = !_isStarred;
    });
    await prefs.setBool('starred_$article', _isStarred);
  }

  void _loadReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isRead = prefs.getBool('read_$article') ?? false;
    });
  }

  void _toggleRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isRead = !_isRead;
    });
    await prefs.setBool('read_$article', _isRead);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(article),
        subtitle: Text(day),
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Prevent Row from taking full width
          children: [
            IconButton(
              icon: Icon(_isStarred ? Icons.star : Icons.star_border),
              onPressed: _toggleStarred,
            ),
            IconButton(
              icon: Icon(_isRead ? Icons.check_circle : Icons.check_circle_outline), 
              onPressed: _toggleRead,
            ),
          ],
        ),
      ),
    );
  }
}
