// lib/services/saved_looks_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/saved_look.dart';

class SavedLooksService {
  Future<List<SavedLook>> fetchLooks() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/saved-looks');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load saved looks');
    }
    final List data = jsonDecode(response.body) as List;
    return data.map((e) => SavedLook.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveLook({required String analysisId, String collectionName = 'Favorites', String? note}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/saved-looks');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'analysis_id': analysisId,
        'collection_name': collectionName,
        'note': note,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save look');
    }
  }

  Future<void> deleteLook(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/saved-looks/$id');
    final response = await http.delete(uri);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete saved look');
    }
  }
}