import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;

  Future<CameraController> initialize() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    return _controller!;
  }

  void dispose() {
    _controller?.dispose();
  }
}