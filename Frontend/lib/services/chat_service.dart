// lib/services/chat_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ChatService {
  Future<String> sendMessage({
    required String categoryId,
    required String sessionId,
    required String message,
    String? analysisId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/$categoryId/chat');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_id': sessionId,
        'message': message,
        if (analysisId != null) 'analysis_id': analysisId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['reply'] as String;
  }

  Future<List<Map<String, dynamic>>> fetchHistory({
    required String categoryId,
    required String sessionId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/$categoryId/chat/$sessionId/history');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load chat history (${response.statusCode})');
    }
    return List<Map<String, dynamic>>.from(jsonDecode(response.body) as List);
  }

  Future<void> clearHistory({
    required String categoryId,
    required String sessionId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/$categoryId/chat/$sessionId');
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to clear chat (${response.statusCode})');
    }
  }

  String _extractError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['detail'] != null) return decoded['detail'].toString();
    } catch (_) {}
    return 'Server error (${response.statusCode})';
  }
}