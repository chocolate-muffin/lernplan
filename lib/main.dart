import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<dynamic>> articleData; // Store the future

  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    articleData = loadArticleData(); // Load data when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: articleData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount:
                  snapshot.data!.length, // Use the length of 'days' array
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
                                                onTap: () {
                                                  openInBrowser(
                                                      article['link']);
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your logic here
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<List<dynamic>> loadArticleData() async {
  String jsonString = await rootBundle.loadString('assets/article_data.json');
  final jsonResponse = json.decode(jsonString);
  return jsonResponse['days']; // Extract the 'days' array
}

// Function to open URL in a new browser tab
Future<void> openInBrowser(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(
      url,
      mode: LaunchMode.externalApplication, // Open in external browser
    );
  } else {
    // Handle the case where the URL cannot be launched
    print('Could not launch $url');
  }
}
