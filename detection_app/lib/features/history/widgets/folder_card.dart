import 'package:flutter/material.dart';
// import '../../../core/constants/app_colors.dart';

class FolderCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const FolderCard({super.key, required this.title, required this.count, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2), // สีจางๆ
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.folder, color: color, size: 32),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("$count items", style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}