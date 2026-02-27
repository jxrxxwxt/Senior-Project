import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFF37E12); // สีส้ม
  static const Color primaryDark = Color(0xFFD6690B);
  
  // *** เพิ่มตัวนี้ (แก้ Error: Member not found: 'primarySoft') ***
  static const Color primarySoft = Color(0xFFFFF3E0); 

  static const Color background = Color(0xFFFAFAFA); // พื้นหลังขาวนวล
  static const Color cardBg = Colors.white;
  
  // *** เพิ่มตัวนี้ (แก้ Error: Member not found: 'border') ***
  static const Color border = Color(0xFFEDF1F7); 
  
  static const Color textDark = Color(0xFF1A2B48);
  static const Color textGrey = Color(0xFF8F9BB3);
  static const Color textLight = Color(0xFFC5CEE0);

  static const Color success = Color(0xFFE8F5E9);
  static const Color successText = Color(0xFF2E7D32);
  static const Color error = Color(0xFFFFEBEE);
  static const Color errorText = Color(0xFFD32F2F);
  
  static const Color specimenColor = Color(0xFFF37E12);
  static const Color pureCultureColor = Color(0xFF8A56AC);

  // สีเฉพาะ Folder
  static const Color purpleIcon = Color(0xFF9C27B0);
  static const Color purpleSoft = Color(0xFFF3E5F5);
}