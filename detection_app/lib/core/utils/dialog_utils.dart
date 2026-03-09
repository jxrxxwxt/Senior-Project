import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DialogUtils {
  
  // 1. Loading Dialog
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow:[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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

  // 2. Error / Alert Dialog (แบบที่คุณส่งรูปมา)
  static void showError(BuildContext context, String message, {String title = "Oops!"}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.error_rounded, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message, style: const TextStyle(fontSize: 15, color: AppColors.textGrey, height: 1.5), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Okay", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. ★ ธีม Confirm Dialog (สำหรับลบข้อมูล) ที่ถอดแบบมาจาก showError ★
  static void showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = "Delete",
    Color confirmColor = Colors.red,
    IconData icon = Icons.delete_outline_rounded,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              // ไอคอนวงกลม
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: confirmColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: confirmColor, size: 32),
              ),
              const SizedBox(height: 16),
              // หัวข้อ
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              // รายละเอียด
              Text(message, style: const TextStyle(fontSize: 15, color: AppColors.textGrey, height: 1.5), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              // ปุ่มกดยืนยัน / ยกเลิก
              Row(
                children:[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFEDF1F7)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: AppColors.textDark,
                      ),
                      child: const Text("Cancel", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onConfirm(); // สั่งทำงานที่ส่งเข้ามา
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(confirmText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // 4. Success Toast (ลอยจากด้านบน)
  static void showSuccess(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(builder: (context) => _TopToast(message: message));
    overlay.insert(overlayEntry);
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
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _offsetAnimation = Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Align(alignment: Alignment.topCenter, child: SlideTransition(position: _offsetAnimation, child: Material(color: Colors.transparent, child: Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: const Color(0xFF1B1B1B).withValues(alpha: 0.9), borderRadius: BorderRadius.circular(16), boxShadow:[BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))]), child: Row(mainAxisSize: MainAxisSize.min, children:[const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20), const SizedBox(width: 12), Text(widget.message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))]))))));
  }
}