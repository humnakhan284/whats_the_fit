// lib/models/daily_tip.dart
class DailyTip {
  final String tip;
  final String? category;

  DailyTip({required this.tip, this.category});

  factory DailyTip.fromJson(Map<String, dynamic> json) {
    return DailyTip(
      tip: json['tip'] as String,
      category: json['category'] as String?,
    );
  }
}