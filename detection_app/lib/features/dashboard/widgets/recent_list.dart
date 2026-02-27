import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RecentList extends StatelessWidget {
  const RecentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Analyses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 12),
        _buildItem("Sample Analysis #147", "Feb 3, 02:30 PM", "96.5%", "Specimen"),
        _buildItem("Sample Analysis #146", "Feb 3, 11:15 AM", "93.2%", "Pure Culture"),
        _buildItem("Sample Analysis #145", "Feb 2, 04:45 PM", "95.8%", "Specimen"),
      ],
    );
  }

  Widget _buildItem(String title, String date, String acc, String type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: type == "Specimen" ? Colors.orange[50] : Colors.purple[50], borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.analytics_outlined, color: type == "Specimen" ? Colors.orange : Colors.purple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(acc, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text(type, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}