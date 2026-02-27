import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/apple_sheet_wrapper.dart';
import '../../../data/models/history_item.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/history_provider.dart';
import '../../auth/screens/login_screen.dart';
import 'folder_detail_screen.dart';
import 'history_detail_screen.dart';

class HistoryListScreen extends StatefulWidget {
  const HistoryListScreen({super.key});

  @override
  State<HistoryListScreen> createState() => _HistoryListScreenState();
}

class _HistoryListScreenState extends State<HistoryListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (!auth.isGuest) {
        Provider.of<HistoryProvider>(context, listen: false).fetchAllData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // -------------------------------------------------------------
    // 1. Guest Mode View
    // -------------------------------------------------------------
    if (auth.isGuest) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                      child: const Icon(Icons.lock_outline, size: 20, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Guest User", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                        Text("Limited Access", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30), 
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), 
                      child: Icon(Icons.lock_outline_rounded, size: 60, color: Colors.grey.shade400)
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "History Not Available", 
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0), 
                      child: Text(
                        "To access dashboard features, statistics, and history, please sign in with your account.", 
                        textAlign: TextAlign.center, 
                        style: TextStyle(color: Colors.grey.shade600, height: 1.5)
                      )
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF37E12),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.login_rounded, size: 20),
                      label: const Text("Sign In to Continue", style: TextStyle(fontWeight: FontWeight.bold))
                    )
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      );
    }

    // -------------------------------------------------------------
    // 2. Member Mode View
    // -------------------------------------------------------------
    return Consumer<HistoryProvider>(
      builder: (context, provider, _) {
        final folders = provider.getUniqueFolders();

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false, 
            title: const Text(
              "History", 
              style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 24)
            ),
            actions: provider.isSelectionMode
                ?[
                    TextButton(
                      onPressed: () => provider.selectAll(),
                      child: Text(
                        provider.selectedIds.length == provider.items.length && provider.items.isNotEmpty
                            ? "Deselect All" : "Select All",
                        style: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () => provider.toggleSelectionMode(),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ]
                :[
                    TextButton.icon(
                      onPressed: () => provider.toggleSelectionMode(),
                      icon: const Icon(Icons.check_box_outlined, size: 18, color: AppColors.textGrey),
                      label: const Text(
                        "Select",
                        style: TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
          ),
          body: Column(
            children:[
              // --- Search Bar & Filter ---
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children:[
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(12)),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => provider.setSearchQuery(v),
                          decoration: const InputDecoration(
                            hintText: "Search by name or note...",
                            hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: AppColors.textGrey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const FilterSheet(),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 48, width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEDF1F7)),
                        ),
                        child: const Icon(Icons.filter_list, color: AppColors.textDark, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Scrollable Content ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 40),
                  children:[
                    
                    // --- Selection Status Bar ---
                    if (provider.isSelectionMode)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            Text(
                              "${provider.selectedIds.length} item(s) selected",
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            if (provider.selectedIds.isNotEmpty)
                              InkWell(
                                onTap: () => _showDeleteConfirm(context, provider),
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Row(
                                    children:[
                                      Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                      SizedBox(width: 4),
                                      Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                    // --- Folders Section ---
                    if (_searchCtrl.text.isEmpty && folders.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text("Folders", style: TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                      
                      GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), 
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: folders.length,
                        itemBuilder: (context, index) {
                          final folderName = folders[index];
                          final count = provider.getCountInFolder(folderName);
                          return _buildFolderCard(folderName, count);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // --- All Items ---
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text("All Items", style: TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),

                    if (provider.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40), 
                        child: Center(child: Text("No items found", style: TextStyle(color: Colors.grey)))
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: provider.items.map((item) => _buildHistoryItem(item, provider)).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---

  Widget _buildFolderCard(String title, int count) {
    Color iconColor = const Color(0xFFFF7043); 
    Color bgColor = const Color(0xFFFBE9E7);

    if (title.toLowerCase().contains("blood")) {
      iconColor = const Color(0xFFFF9800);
      bgColor = const Color(0xFFFFF3E0);
    } else if (title.toLowerCase().contains("urine")) {
      iconColor = const Color(0xFFFFB74D);
      bgColor = const Color(0xFFFFF8E1);
    } else if (title.toLowerCase().contains("respiratory")) {
      iconColor = const Color(0xFF64B5F6);
      bgColor = const Color(0xFFE3F2FD);
    }

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FolderDetailScreen(folderName: title))),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12), 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent), 
          boxShadow:[BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.folder_rounded, color: iconColor, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text("$count items", style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(HistoryItem item, HistoryProvider provider) {
    final isSelected = provider.selectedIds.contains(item.id);
    final dateStr = "${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year}"; 
    
    String subtitleStr = "$dateStr • ${item.accuracy}%";
    if (item.gramType != "Unknown" && item.gramType.isNotEmpty) {
      subtitleStr += " • ${item.gramType}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: isSelected ? 1.5 : 1),
        boxShadow:[BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (provider.isSelectionMode) {
              provider.toggleItemSelection(item.id);
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryDetailScreen(item: item)));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children:[
                if (provider.isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                    ),
                  ),

                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.description_outlined, color: AppColors.textDark, size: 24),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      Text(subtitleStr, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
                    ],
                  ),
                ),

                if (!provider.isSelectionMode)
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ★ Custom Delete Confirmation Dialog (สวยงามตามแบบใหม่) ★
  void _showDeleteConfirm(BuildContext context, HistoryProvider provider) {
    showDialog(
      context: context, 
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE), // Red 50
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              
              const Text(
                "Delete Items?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                "Are you sure you want to delete ${provider.selectedIds.length} items?\nThis action cannot be undone.",
                style: const TextStyle(fontSize: 15, color: AppColors.textGrey, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFEDF1F7)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: AppColors.textDark,
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        provider.deleteSelectedItems();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 📌 Filter Sheet UI 
// ---------------------------------------------------------------------------

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});
  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String _date = 'All Time';
  String _gram = 'All Types';
  String _shape = 'All Shapes';

  @override
  Widget build(BuildContext context) {
    return AppleSheetWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children:[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                const SizedBox(width: 24), 
                const Text("Filter Results", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context))
              ],
            ),
            const Text("Refine your search with these filters", style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
            const SizedBox(height: 32),

            _buildSelector("Date Range", _date,['All Time', 'Today', 'This Week'], (v) => setState(() => _date = v)),
            _buildSelector("Gram Type", _gram,['All Types', 'Gram-positive', 'Gram-negative'], (v) => setState(() => _gram = v)),
            _buildSelector("Bacterial Shape", _shape,['All Shapes', 'Cocci', 'Bacilli'], (v) => setState(() => _shape = v)),

            const SizedBox(height: 32),
            Row(
              children:[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () { 
                       Provider.of<HistoryProvider>(context, listen: false).resetFilters();
                       Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE4E9F2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: AppColors.textDark,
                    ),
                    child: const Text("Reset"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<HistoryProvider>(context, listen: false).setFilters(date: _date, gram: _gram, shape: _shape);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Apply", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSelector(String label, String value, List<String> options, Function(String) onSelect) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey),
                dropdownColor: Colors.white,
                items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 15)))).toList(),
                onChanged: (v) => onSelect(v!),
              ),
            ),
          )
        ],
      ),
    );
  }
}