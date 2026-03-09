// import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _apiService.client.post('/auth/login', data: {
        "username": username,
        "password": password,
      });
      
      final token = response.data['access_token'];
      await StorageService.saveToken(token);
      await StorageService.saveUsername(response.data['username']);
      
      return UserModel(
        username: response.data['username'],
        department: response.data['department'],  // ← เพิ่มตรงนี้
      );
    } catch (e) {
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  Future<void> register(String username, String email, String department, String password) async {
    try {
      await _apiService.client.post('/auth/register', data: {
        "username": username,
        "email": email,
        "department": department,
        "password": password,
      });
    } catch (e) {
      throw Exception("Registration failed");
    }
  }
}