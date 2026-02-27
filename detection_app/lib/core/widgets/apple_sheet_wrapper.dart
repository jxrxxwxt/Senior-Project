import 'package:flutter/material.dart';

class AppleSheetWrapper extends StatelessWidget {
  final Widget child;
  const AppleSheetWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle Bar (ขีดเทาๆ ด้านบน)
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          child, // เนื้อหาข้างใน
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16), // เว้นระยะ Safe Area
        ],
      ),
    );
  }
}