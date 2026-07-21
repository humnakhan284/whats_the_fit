// lib/services/daily_tip_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/daily_tip.dart';

class DailyTipService {
  Future<DailyTip> fetchTip() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/daily-tip');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load tip (${response.statusCode})');
    }
    return DailyTip.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}