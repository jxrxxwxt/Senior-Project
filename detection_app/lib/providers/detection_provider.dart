import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/analysis_result.dart';
import '../data/repositories/detection_repository.dart';

class DetectionProvider extends ChangeNotifier {
  final DetectionRepository _repository = DetectionRepository();
  
  bool _isLoading = false;
  String? _errorMessage;
  AnalysisResult? _currentResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AnalysisResult? get currentResult => _currentResult;

  /// ส่งรูปภาพไปวิเคราะห์ที่ API
  Future<bool> analyzeImage(File image, String modelType) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentResult = await _repository.analyzeImage(image, modelType);
      _isLoading = false;
      notifyListeners();
      return true; // สำเร็จ
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false; // ล้มเหลว
    }
  }

  /// ล้างค่าเมื่อออกจากหน้า Result
  void clearResult() {
    _currentResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}