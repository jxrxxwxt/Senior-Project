class AnalysisResult {
  final String modelUsed;
  final String gramType;
  final String shape;
  final double accuracy;
  final DateTime timestamp;

  AnalysisResult({
    required this.modelUsed,
    required this.gramType,
    required this.shape,
    required this.accuracy,
    required this.timestamp,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      modelUsed: json['model_used'] ?? '',
      gramType: json['gram_type'] ?? 'Unknown',
      shape: json['shape'] ?? 'Unknown',
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}