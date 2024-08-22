import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsSecreen extends StatefulWidget {
  const SettingsSecreen({super.key});

  @override
  State<SettingsSecreen> createState() => _SettingsSecreenState();
}

class _SettingsSecreenState extends State<SettingsSecreen> {
  bool _moveStarredToTop = false;

  @override
  void initState() {
    super.initState();
    _loadSortingPreference();
  }
  void _loadSortingPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _moveStarredToTop = prefs.getBool('moveStarredToTop') ?? false;
    });
  }
  void _toggleSortingPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _moveStarredToTop = !_moveStarredToTop;
      prefs.setBool('moveStarredToTop', _moveStarredToTop);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Move Starred Articles to the Top'),
              value: _moveStarredToTop,
              onChanged: (value) {
                _toggleSortingPreference();
              },
            ),
            // Add other settings options here
          ],
        ),
      ),
    );
  }
}