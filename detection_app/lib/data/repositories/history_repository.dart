import 'package:dio/dio.dart';
import '../models/history_item.dart';
import '../services/api_service.dart';

class HistoryRepository {
  final ApiService _apiService = ApiService();

  Future<List<HistoryItem>> getHistory({String? folder}) async {
    try {
      final response = await _apiService.client.get('/history', queryParameters: {
        if (folder != null && folder != 'All Items') 'folder': folder,
      });
      
      return (response.data as List)
          .map((item) => HistoryItem.fromJson(item))
          .toList();
    } catch (e) {
      return []; 
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiService.client.get('/history/dashboard-stats');
      return response.data;
    } catch (e) {
      return {"total": 0, "avg_accuracy": 0.0, "today_count": 0};
    }
  }

  Future<void> saveHistory(Map<String, dynamic> data) async {
    await _apiService.client.post('/history/', data: data);
  }
  
  Future<void> deleteHistoryItem(int id) async {
    await _apiService.client.delete('/history/$id');
  }
}