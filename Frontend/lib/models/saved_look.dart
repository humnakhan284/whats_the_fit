// lib/models/saved_look.dart
// Matches SavedLookOut exactly — backend does NOT return image/category here,
// only a pointer to the Analysis. Screen joins with HistoryService itself.
class SavedLook {
  final String id;
  final String analysisId;
  final String collectionName;
  final String? note;
  final DateTime createdAt;

  SavedLook({
    required this.id,
    required this.analysisId,
    required this.collectionName,
    required this.createdAt,
    this.note,
  });

  factory SavedLook.fromJson(Map<String, dynamic> json) {
    return SavedLook(
      id: json['id'] as String,
      analysisId: json['analysis_id'] as String,
      collectionName: json['collection_name'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class CollectionSummary {
  final String collectionName;
  final int count;

  CollectionSummary({required this.collectionName, required this.count});

  factory CollectionSummary.fromJson(Map<String, dynamic> json) {
    return CollectionSummary(
      collectionName: json['collection_name'] as String,
      count: json['count'] as int,
    );
  }
}