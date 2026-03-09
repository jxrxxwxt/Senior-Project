import 'package:flutter/material.dart';
import '../data/models/history_item.dart';
import '../data/models/folder_model.dart';
import '../data/repositories/history_repository.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryRepository _repository = HistoryRepository();

  // --- Data Sources ---
  List<HistoryItem> _allItems = [];
  List<HistoryItem> _displayItems =[];
  
  List<FolderModel> _allFolders = [];
  List<FolderModel> _displayFolders =[];
  
  bool _isLoading = false;
  
  // --- Selection Mode State ---
  bool _isSelectionMode = false;
  final Set<int> _selectedItemIds = {};
  final Set<int> _selectedFolderIds = {};

  // --- Filter State ---
  String _searchQuery = '';
  String _filterDate = 'All Time';
  String _filterGram = 'All Types';
  String _filterShape = 'All Shapes';

  // --- Stats ---
  int _totalAnalyses = 0;
  double _avgAccuracy = 0.0;
  int _todayCount = 0;

  // --- Getters ---
  List<HistoryItem> get items => _displayItems;
  List<FolderModel> get folders => _displayFolders;
  bool get isLoading => _isLoading;
  bool get isSelectionMode => _isSelectionMode;
  Set<int> get selectedIds => _selectedItemIds;
  Set<int> get selectedFolderIds => _selectedFolderIds;

  int get totalAnalyses => _totalAnalyses;
  double get avgAccuracy => _avgAccuracy;
  int get todayCount => _todayCount;

  List<HistoryItem> get recentItems => _allItems.take(5).toList();

  // --- Main Fetch Data ---
  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getFolders(),
        _repository.getHistory(),
        _repository.getDashboardStats()
      ]);

      _allFolders = results[0] as List<FolderModel>;
      _allItems = results[1] as List<HistoryItem>;
      
      final stats = results[2] as Map<String, dynamic>;
      _totalAnalyses = stats['total'] ?? 0;
      _avgAccuracy = (stats['avg_accuracy'] ?? 0.0).toDouble();
      _todayCount = stats['today_count'] ?? 0;

      _applyFilters();
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
    final q = _searchQuery.toLowerCase();

    // 1. กรอง Items
    _displayItems = _allItems.where((item) {
      bool matchesSearch = true;
      if (q.isNotEmpty) {
        final matchName = item.itemName.toLowerCase().contains(q);
        final matchNote = (item.note ?? "").toLowerCase().contains(q);
        final folderName = getFolderName(item.folderId).toLowerCase();
        final matchFolder = folderName.contains(q);
        matchesSearch = matchName || matchNote || matchFolder;
      }
      bool matchesGram = _filterGram == 'All Types' || item.gramType == _filterGram;
      bool matchesShape = _filterShape == 'All Shapes' || item.shape == _filterShape;
      bool matchesDate = true;
      if (_filterDate != 'All Time') {
        final now = DateTime.now();
        if (_filterDate == 'Today') {
          matchesDate = item.timestamp.year == now.year && item.timestamp.month == now.month && item.timestamp.day == now.day;
        } else if (_filterDate == 'This Week') {
           final weekAgo = now.subtract(const Duration(days: 7));
           matchesDate = item.timestamp.isAfter(weekAgo);
        }
      }
      return matchesSearch && matchesGram && matchesShape && matchesDate;
    }).toList();

    // 2. กรอง Folders
    _displayFolders = _allFolders.where((folder) {
      if (q.isEmpty) return true;
      return folder.name.toLowerCase().contains(q);
    }).toList();
    
    notifyListeners();
  }

  // --- Helper Methods สำหรับ Folder ---
  String getFolderName(int? folderId) {
    if (folderId == null) return "General";
    try {
      return _allFolders.firstWhere((f) => f.id == folderId).name;
    } catch (e) {
      return "Unknown";
    }
  }

  int getCountInFolder(int? folderId) {
    return _allItems.where((item) => item.folderId == folderId).length;
  }

  // --- Mutations (สร้าง/บันทึก/ลบ) ---
  Future<void> createNewFolder(String name) async {
    await _repository.createFolder(name);
    await fetchAllData();
  }

  Future<void> addHistoryItem(Map<String, dynamic> data) async {
    await _repository.saveHistory(data);
    await fetchAllData();
  }

  // --- Selection Mode ---
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    _selectedItemIds.clear(); 
    _selectedFolderIds.clear();
    notifyListeners();
  }

  void toggleItemSelection(int id) {
    if (_selectedItemIds.contains(id)) {
      _selectedItemIds.remove(id);
    } else {
      _selectedItemIds.add(id);
    }
    notifyListeners();
  }

  void toggleFolderSelection(int id) {
    if (_selectedFolderIds.contains(id)) {
      _selectedFolderIds.remove(id);
    } else {
      _selectedFolderIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    bool allItemsSelected = _selectedItemIds.length == _displayItems.length;
    bool allFoldersSelected = _selectedFolderIds.length == _displayFolders.length;

    if (allItemsSelected && allFoldersSelected) {
      _selectedItemIds.clear(); _selectedFolderIds.clear();
    } else {
      _selectedItemIds.clear(); _selectedFolderIds.clear();
      _selectedItemIds.addAll(_displayItems.map((e) => e.id));
      _selectedFolderIds.addAll(_displayFolders.map((e) => e.id));
    }
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    _isLoading = true; notifyListeners();
    try {
      if (_selectedItemIds.isNotEmpty) await _repository.deleteMultipleHistoryItems(_selectedItemIds.toList());
      for (int folderId in _selectedFolderIds) {
        await _repository.deleteFolder(folderId);
      }
      
      await fetchAllData();
      _isSelectionMode = false; _selectedItemIds.clear(); _selectedFolderIds.clear();
    } catch (e) {
      debugPrint("Delete failed: $e");
    } finally {
      _isLoading = false; notifyListeners();
    }
  }
}