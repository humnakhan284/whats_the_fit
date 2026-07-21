// lib/services/trends_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/trend_item.dart';

class TrendsService {
  Future<List<TrendItem>> fetchTrends({String? region, String? season}) async {
    final params = <String, String>{};
    if (region != null) params['region'] = region;
    if (season != null) params['season'] = season;
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/trends').replace(queryParameters: params.isEmpty ? null : params);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load trends (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final List trends = body['trends'] as List;
    return trends.map((e) => TrendItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}