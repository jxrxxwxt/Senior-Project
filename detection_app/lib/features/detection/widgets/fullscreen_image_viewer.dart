import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/dialog_utils.dart';

class FullscreenImageViewer extends StatefulWidget {
  final String imageBase64;
  final String? title;
  final bool isAnnotated;

  const FullscreenImageViewer({
    super.key,
    required this.imageBase64,
    this.title,
    this.isAnnotated = false,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  bool _isSaving = false;

  Future<void> _saveToGallery() async {
    if (_isSaving) return;

    _isSaving = true;
    DialogUtils.showLoading(context);

    try {
      // ขออนุญาต
      final status = await Permission.photos.request();

      if (status.isDenied) {
        if (mounted) {
          DialogUtils.hideLoading(context);
          DialogUtils.showError(context, "Photo permission denied");
        }
        _isSaving = false;
        return;
      }

      if (status.isPermanentlyDenied) {
        if (mounted) {
          DialogUtils.hideLoading(context);
          DialogUtils.showError(context, "Photo permission permanently denied. Please enable in settings.");
          openAppSettings();
        }
        _isSaving = false;
        return;
      }

      // แปลง base64 -> bytes
      final bytes = base64Decode(widget.imageBase64);

      // บันทึกโดยใช้ gal package
      await Gal.putImageBytes(
        bytes,
        name: "bacteria_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      if (mounted) {
        DialogUtils.hideLoading(context);
        DialogUtils.showSuccess(context, "Image saved to gallery!");
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.hideLoading(context);
        DialogUtils.showError(context, "Error saving image: $e");
      }
    } finally {
      _isSaving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // แปลง base64 -> Image widget
    final imageBytes = base64Decode(widget.imageBase64);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.title ?? "Image Viewer",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // ปุ่มบันทึก
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveToGallery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isSaving ? "Saving..." : "Save to Gallery",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
