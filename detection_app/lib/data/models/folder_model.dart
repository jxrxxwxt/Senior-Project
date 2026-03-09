class FolderModel {
  final int id;
  final String name;
  final int itemCount;
  final DateTime createdAt;

  FolderModel({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.createdAt,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'],
      name: json['name'],
      itemCount: json['item_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}