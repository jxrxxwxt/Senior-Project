class HistoryItem {
  final int id;
  final String itemName;
  final DateTime timestamp;
  final String modelUsed;
  final String gramType;
  final String shape;
  final double accuracy;
  final String? note;
  final int? folderId; // ★ เพิ่มตัวนี้ (Foreign Key ไปหา Folder)

  HistoryItem({
    required this.id,
    required this.itemName,
    required this.timestamp,
    required this.modelUsed,
    required this.gramType,
    required this.shape,
    required this.accuracy,
    this.note,
    this.folderId, // ★ เพิ่มใน Constructor
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
      folderId: json['folder_id'], // ★ รับค่า int หรือ null จาก API
    );
  }
}