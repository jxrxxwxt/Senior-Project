import 'package:flutter/foundation.dart';
import '../models/history_item.dart';
import '../models/folder_model.dart';
import '../services/api_service.dart';

class HistoryRepository {
  final ApiService _apiService = ApiService();

  Future<List<FolderModel>> getFolders({String? search}) async {
    try {
      final response =
          await _apiService.client.get('/history/folders', queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      });
      return (response.data as List)
          .map((item) => FolderModel.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<FolderModel?> createFolder(String name) async {
    try {
      final response = await _apiService.client.post(
        '/history/folders',
        data: {"name": name},
      );
      return FolderModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteFolder(int folderId) async {
    await _apiService.client.delete('/history/folders/$folderId');
  }

  Future<List<HistoryItem>> getHistory({int? folderId, String? search}) async {
    try {
      final response =
          await _apiService.client.get('/history/', queryParameters: {
        if (folderId != null) 'folder_id': folderId,
        if (search != null && search.isNotEmpty) 'search': search,
      });

      return (response.data as List)
          .map((item) => HistoryItem.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<HistoryItem> getHistoryDetail(int id) async {
    final response = await _apiService.client.get('/history/$id');
    return HistoryItem.fromJson(response.data);
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiService.client.get('/history/stats/summary');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Repo Stats Error: $e");
      return {};
    }
  }

  Future<void> saveHistory(Map<String, dynamic> data) async {
    await _apiService.client.post('/history/', data: data);
  }

  Future<void> deleteHistoryItem(int id) async {
    await _apiService.client.delete('/history/$id');
  }

  Future<void> deleteMultipleHistoryItems(List<int> ids) async {
    await _apiService.client.delete(
      '/history/batch/delete',
      queryParameters: {"item_ids": ids},
    );
  }
}
