class HistoryItem {
  final int id;
  final String itemName;
  final DateTime timestamp;
  final String modelUsed;
  final String gramType;
  final String shape;
  final double accuracy;
  final String? folderName;
  final String? note;

  HistoryItem({
    required this.id,
    required this.itemName,
    required this.timestamp,
    required this.modelUsed,
    required this.gramType,
    required this.shape,
    required this.accuracy,
    this.folderName,
    this.note,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] ?? 0,
      itemName: json['item_name'] ?? 'Unknown Sample',
      timestamp: DateTime.parse(json['timestamp']),
      modelUsed: json['model_used'] ?? '',
      gramType: json['gram_type'] ?? '',
      shape: json['shape'] ?? '',
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      folderName: json['folder_name'] ?? 'General',
      note: json['note'],
    );
  }
}