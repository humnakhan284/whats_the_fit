// lib/services/weather_style_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/analyze_response.dart';

class WeatherStyleService {
  Future<AnalyzeResponse> suggest({
    String? weatherDescription,
    double? temperatureC,
    String? season,
    String? preference,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/weather-style');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (weatherDescription != null) 'weather_description': weatherDescription,
        if (temperatureC != null) 'temperature_c': temperatureC,
        if (season != null) 'season': season,
        if (preference != null) 'preference': preference,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed (${response.statusCode})');
    }
    return AnalyzeResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}