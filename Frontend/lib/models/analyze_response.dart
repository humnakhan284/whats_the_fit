// lib/models/analyze_response.dart
// Generic response shared by outfit-generator / color-palette / weather-style
class AnalyzeResponse {
  final String analysisId;
  final String category;
  final Map<String, dynamic> result;

  AnalyzeResponse({required this.analysisId, required this.category, required this.result});

  factory AnalyzeResponse.fromJson(Map<String, dynamic> json) {
    return AnalyzeResponse(
      analysisId: json['analysis_id'] as String,
      category: json['category'] as String,
      result: Map<String, dynamic>.from(json['result'] as Map),
    );
  }
}