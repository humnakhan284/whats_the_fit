// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Theme'),
            subtitle: const Text('Toggle app appearance'),
            value: _darkMode,
            activeColor: AppColors.gradientEnd,
            onChanged: (val) => setState(() => _darkMode = val),
          ),
          const Divider(),
          const ListTile(
            title: Text('About What\'s the Fit?'),
            subtitle: Text('Version 1.0.0 • AI Fashion Suite'),
          ),
        ],
      ),
    );
  }
}