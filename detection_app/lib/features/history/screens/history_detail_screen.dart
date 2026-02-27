import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/history_item.dart';

class HistoryDetailScreen extends StatelessWidget {
  final HistoryItem item;
  const HistoryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.itemName), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Model Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text("Model Used", style: TextStyle(color: Colors.white70)),
                  Text(item.modelUsed, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Image Placeholder (เนื่องจาก History API เราไม่ได้ส่งรูป Base64 กลับมา เราจะใช้ Placeholder แทน หรือต้องแก้ API ให้ส่ง URL รูป)
            Container(
              height: 250, width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Analysis Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(height: 30),
                  _detailRow("Timestamp", DateFormat('MMM d, yyyy h:mm a').format(item.timestamp)),
                  _detailRow("Accuracy", "${item.accuracy}%", isHighlight: true),
                  _detailRow("Gram Type", item.gramType),
                  _detailRow("Shape", item.shape),
                  _detailRow("Folder", item.folderName ?? "General"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Note Card
            if (item.note != null && item.note!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [Icon(Icons.note, size: 20), SizedBox(width: 8), Text("Note", style: TextStyle(fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 8),
                  Text(item.note!),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isHighlight ? 18 : 14, color: isHighlight ? AppColors.primary : Colors.black)),
        ],
      ),
    );
  }
}