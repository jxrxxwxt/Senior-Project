import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/history_item.dart';

class HistoryItemTile extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback onTap;

  const HistoryItemTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.description_outlined, color: AppColors.textDark),
        ),
        title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year} • ${item.accuracy}%"),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}