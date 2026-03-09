import 'dart:io';
import 'package:camera/camera.dart';
import 'package:detection_app/features/detection/widgets/camera_overlay.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  // ฟังก์ชันเตรียมระบบกล้อง
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) DialogUtils.showError(context, "No cameras found.");
        return;
      }

      // เลือกกล้องหลัง
      final backCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) DialogUtils.showError(context, "Camera Initialization Failed: $e");
    }
  }

  // จัดการเปิด/ปิดกล้องเวลาพับหน้าจอแอป
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // ฟังก์ชันถ่ายรูปและส่งไปวิเคราะห์
  Future<void> _capture() async {
    try {
      await _initializeControllerFuture;
    } catch (e) {
      if (mounted) DialogUtils.showError(context, "Camera not ready.");
      return;
    }

    final photo = await _controller!.takePicture();
    _analyze(File(photo.path));
  }

  Future<void> _analyze(File image) async {
    DialogUtils.showLoading(context);
    try {
      final repo = DetectionRepository();
      final result = await repo.analyzeImage(image, widget.modelName);

      if (mounted) {
        DialogUtils.hideLoading(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(result: result, imageFile: image)),
        );
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.hideLoading(context);
        DialogUtils.showError(context, "Analysis Failed: $e");
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      _analyze(File(photo.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.modelName, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black45, // พื้นหลัง AppBar โปร่งแสง
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. กล้อง (พื้นหลังล่างสุด)
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller!);
              } else {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
            },
          ),

          // 2. กรอบ Overlay 4 มุม (ตรงกลาง)
          const CameraOverlay(),

          // 3. UI ซ้อนทับ (ข้อความและปุ่มกด บนสุด)
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Position sample in frame",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
                      ),
                      GestureDetector(
                        onTap: _capture,
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 30), // Placeholder เพื่อให้ปุ่มกล้องอยู่ตรงกลาง
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}