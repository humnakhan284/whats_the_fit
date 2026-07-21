import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const WhatsTheFitApp());
}

class WhatsTheFitApp extends StatelessWidget {
  const WhatsTheFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "What's the Fit?",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
