class HistoryItem {
  final String id;
  final String category;
  final String? occasion;
  final String? primaryImageUrl;
  final String? secondaryImageUrl;
  final String? imageUrl;
  final String? thumbnailUrl;
  final DateTime? createdAt;

  HistoryItem({
    required this.id,
    required this.category,
    this.occasion,
    this.primaryImageUrl,
    this.secondaryImageUrl,
    this.imageUrl,
    this.thumbnailUrl,
    this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    final pUrl = json['primaryImageUrl'] as String? ?? json['imageUrl'] as String?;
    final sUrl = json['secondaryImageUrl'] as String? ?? json['thumbnailUrl'] as String?;

    return HistoryItem(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      occasion: json['occasion'] as String?,
      primaryImageUrl: pUrl,
      secondaryImageUrl: sUrl,
      imageUrl: json['imageUrl'] as String? ?? pUrl,
      thumbnailUrl: json['thumbnailUrl'] as String? ?? sUrl,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'occasion': occasion,
      'primaryImageUrl': primaryImageUrl,
      'secondaryImageUrl': secondaryImageUrl,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}