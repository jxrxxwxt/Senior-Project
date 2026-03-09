class AnalysisResult {
  final String modelUsed;
  final String gramType;
  final String shape;
  final double accuracy;
  final DateTime timestamp;
  final String originalImageBase64;  // รูปปกติ
  final String annotatedImageBase64; // รูป+bounding box

  AnalysisResult({
    required this.modelUsed,
    required this.gramType,
    required this.shape,
    required this.accuracy,
    required this.timestamp,
    required this.originalImageBase64,
    required this.annotatedImageBase64,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      modelUsed: json['model_used'] ?? '',
      gramType: json['gram_type'] ?? 'Unknown',
      shape: json['shape'] ?? 'Unknown',
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      originalImageBase64: json['original_image_base64'] ?? '',
      annotatedImageBase64: json['annotated_image_base64'] ?? '',
    );
  }
}