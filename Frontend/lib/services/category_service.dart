import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/category_result.dart';

class CategoryService {
  Future<CategoryResult> analyze({
    required File image,
    required String categoryId,
    required String occasion,
    String? notes,
    File? faceImage,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/$categoryId/analyze');
    final request = http.MultipartRequest('POST', uri)
      ..fields['occasion'] = occasion;

    if (notes != null && notes.trim().isNotEmpty) {
      request.fields['additional_prompt'] = notes.trim();
    }

    request.files.add(await http.MultipartFile.fromPath('primary_image', image.path));
    if (faceImage != null) {
      request.files.add(await http.MultipartFile.fromPath('face_image', faceImage.path));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return CategoryResult(
      analysisId: body['analysis_id'] as String,
      category: body['category'] as String,
      result: Map<String, dynamic>.from(body['result'] as Map),
    );
  }

  String _extractError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['detail'] != null) return decoded['detail'].toString();
    } catch (_) {}
    return 'Server error (${response.statusCode})';
  }
}