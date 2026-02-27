import 'dart:io';
import 'package:dio/dio.dart';
import '../models/analysis_result.dart';
import '../services/api_service.dart';

class DetectionRepository {
  final ApiService _apiService = ApiService();

  Future<AnalysisResult> analyzeImage(File imageFile, String modelType) async {
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      "model_type": modelType,
    });

    final response = await _apiService.client.post('/analysis/predict', data: formData);
    return AnalysisResult.fromJson(response.data);
  }
}