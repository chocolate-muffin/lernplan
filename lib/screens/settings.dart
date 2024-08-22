import 'package:flutter/material.dart';
import 'package:lernplan/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsSecreen extends StatefulWidget {
  const SettingsSecreen({super.key});

  @override
  State<SettingsSecreen> createState() => _SettingsSecreenState();
}

class _SettingsSecreenState extends State<SettingsSecreen> {
  bool _moveStarredToTop = false;
  bool _moveReadToBottom = false;

  @override
  void initState() {
    super.initState();
    _loadSortingStarredPreference();
    _loadSortingReadPreference();
  }

  void _loadSortingStarredPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _moveStarredToTop = prefs.getBool('moveStarredToTop') ?? false;
    });
  }

  void _toggleSortingStarredPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _moveStarredToTop = !_moveStarredToTop;
      prefs.setBool('moveStarredToTop', _moveStarredToTop);
    });
  }

  void _loadSortingReadPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _moveReadToBottom = prefs.getBool('moveReadToBottom') ?? false;
    });
  }

  void _toggleSortingReadPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _moveReadToBottom = !_moveReadToBottom;
      prefs.setBool('moveReadToBottom', _moveReadToBottom);
    });
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
 // Wrap the content in SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Move Starred Articles to the Top'),
                value: _moveStarredToTop,
                onChanged: (value) {
                  _toggleSortingStarredPreference();
                },
              ),
              ElevatedButton(
                onPressed: () {
                  _clearStarredPreferences();
                },
                child: const Text('Clear Starred Articles'),
              ),
              SwitchListTile(
                title: const Text('Move Read Articles to the Bottom'),
                value: _moveReadToBottom,
                onChanged: (value) {
                  _toggleSortingReadPreference();
                },
              ),
              ElevatedButton(
                onPressed: () {
                  _clearReadPreferences();
                },
                child: const Text('Clear Read Articles'),
              ),

              // Theme Settings
              const Text('Theme Settings'),
              RadioListTile<ThemeMode>(
                title: const Text('System Theme'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode, // Use provider's value
                onChanged: (value) => themeProvider.setThemeMode(value), 
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light Theme'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) => themeProvider.setThemeMode(value),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Theme'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) => themeProvider.setThemeMode(value),
              ),
              // Add other settings options here
            ],
          ),
        ),
      ),
    );
  }

  void _clearStarredPreferences() async {
    showDialog(
      context: context, // Make sure you have a BuildContext
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Clear'),
          content: const Text(
              'Are you sure you want to clear all starred articles? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // User confirmed, proceed with clearing
                final prefs = await SharedPreferences.getInstance();
                final keysToRemove =
                    prefs.getKeys().where((key) => key.startsWith('starred_'));

                for (final key in keysToRemove) {
                  await prefs.remove(key);
                }

                // Close the dialog
                Navigator.of(context).pop();

                // Optionally, show a confirmation message
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starred articles cleared!')));
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _clearReadPreferences() async {
    showDialog(
      context: context, // Make sure you have a BuildContext
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Clear'),
          content: const Text(
              'Are you sure you want to clear all read articles? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // User confirmed, proceed with clearing
                final prefs = await SharedPreferences.getInstance();
                final keysToRemove =
                    prefs.getKeys().where((key) => key.startsWith('read_'));

                for (final key in keysToRemove) {
                  await prefs.remove(key);
                }

                // Close the dialog
                Navigator.of(context).pop();

                // Optionally, show a confirmation message
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Read articles cleared!')));
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
