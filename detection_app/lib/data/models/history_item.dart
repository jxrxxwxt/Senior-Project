class HistoryItem {
  final int id;
  final String itemName;
  final DateTime timestamp;
  final String modelUsed;
  final String gramType;
  final String shape;
  final double accuracy;
  final String? note;
  final int? folderId;
  final String originalImageBase64;
  final String annotatedImageBase64;

  HistoryItem({
    required this.id,
    required this.itemName,
    required this.timestamp,
    required this.modelUsed,
    required this.gramType,
    required this.shape,
    required this.accuracy,
    this.note,
    this.folderId,
    required this.originalImageBase64,
    required this.annotatedImageBase64,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      itemName: json['item_name'] ?? 'Unknown Sample',
      timestamp: DateTime.parse(json['timestamp']),
      modelUsed: json['model_used'] ?? '',
      gramType: json['gram_type'] ?? '',
      shape: json['shape'] ?? '',
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      note: json['note'],
      folderId: json['folder_id'],
      originalImageBase64: json['original_image_base64'] ?? '',
      annotatedImageBase64: json['annotated_image_base64'] ?? '',
    );
  }
}