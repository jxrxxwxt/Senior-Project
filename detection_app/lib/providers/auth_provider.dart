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

  Future<void> register(String username, String email, String department, String password) async {
    try {
      await _repository.register(username, email, department, password);
      notifyListeners();
    } catch (e) {
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
