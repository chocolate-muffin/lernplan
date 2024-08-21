import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                  articles.where((article) => article.toLowerCase().contains(searchText)).toList(),
                );
              }),
            );

        
            return ListView(
              children: filteredData.entries.expand((entry) {
                final day = entry.key;
                final articles = entry.value;
                return articles.map((article) => Card(
                      child: ListTile(
                        title: Text(article),
                        subtitle: Text(day),
                      ),
                    ));
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
