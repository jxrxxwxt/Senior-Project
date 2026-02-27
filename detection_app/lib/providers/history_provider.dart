import 'package:flutter/material.dart';
import '../data/models/history_item.dart';
import '../data/repositories/history_repository.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryRepository _repository = HistoryRepository();

  List<HistoryItem> _allItems = [];     
  List<HistoryItem> _displayItems =[]; 
  
  bool _isLoading = false;
  
  // Selection Mode State
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};

  // Filter State
  String _searchQuery = '';
  String _filterDate = 'All Time';
  String _filterGram = 'All Types';
  String _filterShape = 'All Shapes';

  // Stats
  int _totalAnalyses = 0;
  double _avgAccuracy = 0.0;
  int _todayCount = 0;

  // --- Getters ---
  List<HistoryItem> get items => _displayItems;
  bool get isLoading => _isLoading;
  
  bool get isSelectionMode => _isSelectionMode;
  Set<int> get selectedIds => _selectedIds;

  int get totalAnalyses => _totalAnalyses;
  double get avgAccuracy => _avgAccuracy;
  int get todayCount => _todayCount;

  List<HistoryItem> get recentItems => _allItems.take(5).toList();

  // --- Main Fetch Data ---
  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allItems = await _repository.getHistory(); 
      _applyFilters(); 
      
      final stats = await _repository.getDashboardStats();
      _totalAnalyses = stats['total'] ?? 0;
      _avgAccuracy = (stats['avg_accuracy'] ?? 0.0).toDouble();
      _todayCount = stats['today_count'] ?? 0;

    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Search & Filter Logic ---

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setFilters({String? date, String? gram, String? shape}) {
    if (date != null) _filterDate = date;
    if (gram != null) _filterGram = gram;
    if (shape != null) _filterShape = shape;
    _applyFilters();
  }

  void resetFilters() {
    _filterDate = 'All Time';
    _filterGram = 'All Types';
    _filterShape = 'All Shapes';
    _searchQuery = '';
    _applyFilters();
  }

  void _applyFilters() {
    _displayItems = _allItems.where((item) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = item.itemName.toLowerCase().contains(q);
        final matchNote = (item.note ?? "").toLowerCase().contains(q);
        final matchFolder = (item.folderName ?? "General").toLowerCase().contains(q);

        if (!matchName && !matchNote && !matchFolder) return false;
      }

      if (_filterGram != 'All Types' && item.gramType != _filterGram) return false;
      if (_filterShape != 'All Shapes' && item.shape != _filterShape) return false;

      if (_filterDate != 'All Time') {
        final now = DateTime.now();
        if (_filterDate == 'Today') {
          return item.timestamp.year == now.year && item.timestamp.month == now.month && item.timestamp.day == now.day;
        } else if (_filterDate == 'This Week') {
           final weekAgo = now.subtract(const Duration(days: 7));
           return item.timestamp.isAfter(weekAgo);
        }
      }

      return true;
    }).toList();
    
    notifyListeners();
  }

  // --- Folder Logic ---

  List<String> getUniqueFolders() {
    final sourceList = _searchQuery.isNotEmpty ? _displayItems : _allItems;
    final folders = sourceList
        .map((item) => item.folderName ?? "General")
        .toSet()
        .toList();
    folders.sort();
    return folders;
  }

  int getCountInFolder(String folderName) {
    final sourceList = _searchQuery.isNotEmpty ? _displayItems : _allItems;
    if (folderName == "General") {
      return sourceList.where((item) => item.folderName == null || item.folderName == "General").length;
    }
    return sourceList.where((item) => item.folderName == folderName).length;
  }

  List<HistoryItem> getItemsByFolder(String folderName) {
    return _allItems.where((item) => (item.folderName ?? "General") == folderName).toList();
  }

  // --- Selection Mode ---

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    _selectedIds.clear();
    notifyListeners();
  }

  void toggleItemSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  // ★ เพิ่มฟังก์ชันนี้เพื่อแก้ Error 'selectAll' ★
  void selectAll() {
    if (_selectedIds.length == _displayItems.length && _displayItems.isNotEmpty) {
      // ถ้าเลือกครบทุกตัวอยู่แล้ว ให้ยกเลิกทั้งหมด
      _selectedIds.clear();
    } else {
      // ถ้ายังเลือกไม่ครบ ให้เลือกทั้งหมดที่แสดงอยู่
      _selectedIds.clear();
      _selectedIds.addAll(_displayItems.map((e) => e.id));
    }
    notifyListeners();
  }

  Future<void> deleteSelectedItems() async {
    try {
      for (var id in _selectedIds) {
         await _repository.deleteHistoryItem(id);
      }
      _allItems.removeWhere((item) => _selectedIds.contains(item.id));
      _applyFilters();
      
      _selectedIds.clear();
      _isSelectionMode = false;
      _totalAnalyses = _allItems.length;
      
      notifyListeners();
    } catch (e) {
      debugPrint("Delete failed: $e");
    }
  }

  // --- Add Data ---

  Future<void> addHistoryItem(Map<String, dynamic> data) async {
    await _repository.saveHistory(data);
    await fetchAllData();
  }
}