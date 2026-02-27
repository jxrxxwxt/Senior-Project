import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  UserModel? _user;
  bool _isGuest = false;

  UserModel? get user => _user;
  bool get isGuest => _isGuest;

  Future<void> login(String username, String password) async {
    _user = await _repository.login(username, password);
    _isGuest = false;
    notifyListeners();
  }

  /// ฟังก์ชันสมัครสมาชิกใหม่
  Future<void> register(String username, String email, String department, String password) async {
    try {
      // 1. เรียกใช้ Repository (ส่งให้ครบ 4 ค่าตามที่ Repository ต้องการ)
      await _repository.register(username, email, department, password);
      
      // 2. หลังจากสมัครสำเร็จ อาจจะทำการ Login ให้เลย หรือให้ผู้ใช้ไป Login เอง
      // ในที่นี้เราแค่แจ้งเตือน UI ว่าทำงานเสร็จแล้ว
      notifyListeners();
    } catch (e) {
      // ส่ง Error กลับไปให้หน้า UI แสดง SnackBar หรือ Alert
      rethrow; 
    }
  }

  void loginAsGuest() {
    _isGuest = true;
    _user = UserModel(username: "Guest User", department: "Limited Access");
    notifyListeners();
  }

  Future<void> logout() async {
    await StorageService.clear();
    _user = null;
    _isGuest = false;
    notifyListeners();
  }
}
