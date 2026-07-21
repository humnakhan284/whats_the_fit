// lib/services/wardrobe_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/wardrobe_item.dart';
import '../models/analyze_response.dart';

class WardrobeService {
  Future<List<WardrobeItem>> fetchItems() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/wardrobe');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load wardrobe (${response.statusCode})');
    }
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => WardrobeItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<WardrobeItem> addItem({
    required File image,
    required String category,
    String? name,
    String? color,
    List<String>? tags,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/wardrobe');
    final request = http.MultipartRequest('POST', uri)..fields['category'] = category;
    if (name != null && name.isNotEmpty) request.fields['name'] = name;
    if (color != null && color.isNotEmpty) request.fields['color'] = color;
    if (tags != null && tags.isNotEmpty) request.fields['tags'] = tags.join(',');
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200) {
      throw Exception('Failed to add item (${response.statusCode})');
    }
    return WardrobeItem.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteItem(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/wardrobe/$id');
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete item (${response.statusCode})');
    }
  }

  Future<AnalyzeResponse> suggestOutfit({String? occasion, String? style, String? categoryFilter}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/wardrobe/suggest');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (occasion != null) 'occasion': occasion,
        if (style != null) 'style': style,
        if (categoryFilter != null) 'category_filter': categoryFilter,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to suggest outfit (${response.statusCode})');
    }
    return AnalyzeResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}