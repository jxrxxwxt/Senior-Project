import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;

  const StatsCard({super.key, required this.title, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
              if (icon != null) Icon(icon, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ],
      ),
    );
  }
}