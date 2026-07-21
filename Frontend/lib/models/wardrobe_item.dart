class WardrobeItem {
  final String id;
  final String? name;
  final String category;
  final String? imageUrl;

  WardrobeItem({
    required this.id,
    this.name,
    required this.category,
    this.imageUrl,
  });

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      category: json['category'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}