import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

// DayList widget
class DayList extends StatefulWidget {
  const DayList({super.key});
  @override
  State<DayList> createState() => _DayListState();
}

class _DayListState extends State<DayList> {
  late Future<List<dynamic>> articleData; // Store the future

  bool isChecked = false;

  
  @override
  void initState() {
    super.initState();
    articleData = loadArticleData(); // Load data when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: articleData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length, // Use the length of 'days' array
            itemBuilder: (context, index) {
              return FutureBuilder<List<dynamic>>(
                future: loadArticleData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final dayData = snapshot.data![index];
                    final articles = dayData['articles'];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 0, // Remove shadow for outlined look
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline, // Use outline color from theme
                        ),
                        borderRadius:
                            BorderRadius.circular(12.0), // Adjust as needed
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ' ${dayData['number'].toString()} - ${dayData['name']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Add your article boxes here
                            for (var article in articles)
                              SizedBox(
                                // Wrap the Card with SizedBox
                                width: double
                                    .infinity, // Set width to take full available space
                                child: Card(
                                  margin: const EdgeInsets.all(4.0),
                                  elevation:
                                      0, // Remove shadow for outlined look
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline, // Use outline color from theme
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        12.0), // Adjust as needed
                                  ),

                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: InkWell(
                                              onTap: () async {
                                                final uri =
                                                    Uri.parse(article['link']);
                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(uri);
                                                } else {
                                                  // Handle the case where the URL cannot be launched
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "Could not launch ${article['link']}"),
                                                    ),
                                                  );
                                                }
                                              },
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              child: Text(article['name']),
                                            ),
                                          ),
                                          Checkbox(
                                            value: isChecked,
                                            onChanged: (value) {
                                              setState(() {
                                                isChecked = value!;
                                              });
                                            },
                                          ),
                                        ],
                                      )),
                                ),
                              )
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text("Error loading data: ${snapshot.error}");
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text("Error loading data: ${snapshot.error}");
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

Future<List<dynamic>> loadArticleData() async {
  String jsonString = await rootBundle.loadString('assets/article_data.json');
  final jsonResponse = json.decode(jsonString);
  return jsonResponse['days']; // Extract the 'days' array
}
