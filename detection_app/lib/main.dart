import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // ล็อคหน้าจอแนวตั้ง
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // ปรับ Status Bar ให้โปร่งใส
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  
  runApp(const DetectionApp());
}