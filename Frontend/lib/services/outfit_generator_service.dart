// lib/services/outfit_generator_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/analyze_response.dart';

class OutfitGeneratorService {
  Future<AnalyzeResponse> generate({
    required String event,
    String? style,
    String? colorPreference,
    String? additionalPrompt,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/outfit-generator');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'event': event,
        if (style != null) 'style': style,
        if (colorPreference != null) 'color_preference': colorPreference,
        if (additionalPrompt != null) 'additional_prompt': additionalPrompt,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to generate outfit (${response.statusCode})');
    }
    return AnalyzeResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}