import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/dialog_utils.dart';
import '../../../data/repositories/detection_repository.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  final String modelName;
  const CameraScreen({super.key, required this.modelName});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _capture(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      _analyze(File(photo.path));
    }
  }

  Future<void> _analyze(File image) async {
    DialogUtils.showLoading(context);
    try {
      final repo = DetectionRepository();
      final result = await repo.analyzeImage(image, widget.modelName);
      
      if (mounted) {
        DialogUtils.hideLoading(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResultScreen(result: result, imageFile: image)));
      }
    } catch (e) {
      if(mounted) {
        DialogUtils.hideLoading(context);
        DialogUtils.showError(context, "Analysis Failed: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.modelName, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const Spacer(),
          const Text("Position sample in frame", style: TextStyle(color: Colors.white70)),
          const Spacer(),
          // Mock Camera View
          Container(
            height: 400, width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(border: Border.all(color: AppColors.primary, width: 2), borderRadius: BorderRadius.circular(20)),
            child: const Center(child: Icon(Icons.camera_alt, size: 50, color: Colors.grey)),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: () => _capture(ImageSource.gallery), icon: const Icon(Icons.photo_library, color: Colors.white, size: 30)),
              GestureDetector(
                onTap: () => _capture(ImageSource.camera),
                child: Container(
                  height: 80, width: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 30), // Placeholder
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}