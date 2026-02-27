import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DialogUtils {
  
  // 1. Loading Dialog (แบบเดิม แต่ปรับให้คลีนขึ้น)
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false, // ป้องกันการกด Back
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }

  // 2. Error / Alert Dialog (ปรับดีไซน์ใหม่ 100%)
  static void showError(BuildContext context, String message, {String title = "Oops!"}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        elevation: 0, // ลบเงา Default ของ Material ออก
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Icon ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1), // พื้นหลังสีแดงจางๆ
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_rounded, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),

              // --- Title ---
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // --- Message ---
              Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textGrey,
                  height: 1.5, // ระยะห่างบรรทัดให้อ่านง่าย
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // --- Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // สีส้มตามธีมแอป
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Okay",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ★ ฟังก์ชันใหม่: แจ้งเตือนสำเร็จแบบลอยจากด้านบน (Apple Style) ★
  static void showSuccess(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _TopToast(message: message),
    );

    overlay.insert(overlayEntry);

    // หายไปเองหลังจาก 3 วินาที
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}

// Widget ภายในสำหรับทำ Toast ด้านบน
class _TopToast extends StatefulWidget {
  final String message;
  const _TopToast({required this.message});

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B).withOpacity(0.9), // สีดำโปร่งแสงแบบ iOS
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}