// lib/models/trend_item.dart
class TrendItem {
  final String name;
  final String description;

  TrendItem({required this.name, required this.description});

  factory TrendItem.fromJson(Map<String, dynamic> json) {
    return TrendItem(name: json['name'] as String, description: json['description'] as String);
  }
}