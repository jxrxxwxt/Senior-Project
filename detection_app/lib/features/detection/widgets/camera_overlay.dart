import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: OverlayPainter(),
        );
      },
    );
  }
}

class OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final double w = size.width;
    final double h = size.height;
    final double cornerSize = 40;
    
    // กำหนดพื้นที่ตรงกลาง (Frame)
    final Rect frame = Rect.fromCenter(center: Offset(w / 2, h / 2), width: w * 0.8, height: w * 0.8);
    final path = Path();

    // Top Left
    path.moveTo(frame.left, frame.top + cornerSize);
    path.lineTo(frame.left, frame.top);
    path.lineTo(frame.left + cornerSize, frame.top);

    // Top Right
    path.moveTo(frame.right - cornerSize, frame.top);
    path.lineTo(frame.right, frame.top);
    path.lineTo(frame.right, frame.top + cornerSize);

    // Bottom Right
    path.moveTo(frame.right, frame.bottom - cornerSize);
    path.lineTo(frame.right, frame.bottom);
    path.lineTo(frame.right - cornerSize, frame.bottom);

    // Bottom Left
    path.moveTo(frame.left + cornerSize, frame.bottom);
    path.lineTo(frame.left, frame.bottom);
    path.lineTo(frame.left, frame.bottom - cornerSize);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}