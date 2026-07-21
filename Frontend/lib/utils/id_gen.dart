import 'dart:math';

/// Generates a simple unique-enough id to use as a chat session_id.
String generateSessionId() {
  final rand = Random();
  final ts = DateTime.now().millisecondsSinceEpoch;
  final suffix = List.generate(8, (_) => rand.nextInt(16).toRadixString(16)).join();
  return '$ts-$suffix';
}