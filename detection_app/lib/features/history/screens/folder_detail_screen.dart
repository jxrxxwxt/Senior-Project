import 'package:detection_app/features/history/widgets/filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/history_item.dart';
import '../../../providers/history_provider.dart';
import 'history_detail_screen.dart';

class FolderDetailScreen extends StatefulWidget {
  final int? folderId; // ★ ใช้ ID ในการอ้างอิง
  final String folderName;
  
  const FolderDetailScreen({
    super.key, 
    required this.folderId, 
    required this.folderName
  });

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset ค้นหาเมื่อเข้าหน้าใหม่ เพื่อให้เห็นรายการทั้งหมดในโฟลเดอร์ก่อน
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false).setSearchQuery("");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, _) {
        // ★ กรองรายการจาก Provider โดยใช้ Folder ID
        final displayItems = provider.items.where((item) {
          return item.folderId == widget.folderId;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false, 
            titleSpacing: 0,    
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.folderName, 
              style: const TextStyle(
                color: AppColors.textDark, 
                fontWeight: FontWeight.bold, 
                fontSize: 24 // ★ Font ใหญ่สะใจตาม Ref
              )
            ),
            actions:[
              TextButton.icon(
                onPressed: () => provider.toggleSelectionMode(),
                icon: Icon(
                  provider.isSelectionMode ? Icons.close : Icons.check_box_outlined, 
                  size: 18, 
                  color: provider.isSelectionMode ? Colors.red : AppColors.textGrey
                ),
                label: Text(
                  provider.isSelectionMode ? "Cancel" : "Select", 
                  style: TextStyle(
                    color: provider.isSelectionMode ? Colors.red : AppColors.textGrey, 
                    fontWeight: FontWeight.w600,
                    fontSize: 14
                  )
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              // -------------------------------------------------------
              // 1. Search Bar & Filter Button
              // -------------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children:[
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC), 
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (val) => provider.setSearchQuery(val),
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
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const FilterSheet(),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 48, width: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEDF1F7)),
                        ),
                        child: const Icon(Icons.tune_rounded, color: AppColors.textDark, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // -------------------------------------------------------
              // 2. Breadcrumbs (All Items > Folder Name)
              // -------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children:[
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "All Items",
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                    ),
                    Expanded(
                      child: Text(
                        widget.folderName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              // -------------------------------------------------------
              // 3. Section Header & Delete Selected
              // -------------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Items in this folder",
                      style: TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    if (provider.isSelectionMode && provider.selectedIds.isNotEmpty)
                       GestureDetector(
                         onTap: () => _showDeleteConfirm(context, provider),
                         child: const Text("Delete Selected", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                       )
                  ],
                ),
              ),

              // -------------------------------------------------------
              // 4. List Items
              // -------------------------------------------------------
              Expanded(
                child: displayItems.isEmpty
                    ? const Center(
                        child: Text("No items match your filters", style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: displayItems.length,
                        itemBuilder: (context, index) {
                          final item = displayItems[index];
                          return _buildItemCard(context, item, provider);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(BuildContext context, HistoryItem item, HistoryProvider provider) {
    final isSelected = provider.selectedIds.contains(item.id);
    final dateStr = DateFormat('dd/MM/yyyy').format(item.timestamp);
    
    String subtitleStr = "$dateStr • ${item.accuracy}%";
    if (item.gramType.isNotEmpty && item.gramType != "Unknown") {
      subtitleStr += " • ${item.gramType}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? Colors.blue : const Color(0xFFEDF1F7), width: isSelected ? 1.5 : 1),
        boxShadow:[
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (provider.isSelectionMode) {
              provider.toggleItemSelection(item.id);
            } else {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => HistoryDetailScreen(item: item)
              ));
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
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.description_outlined, color: AppColors.textDark, size: 24),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text(
                        item.itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleStr,
                        style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                      ),
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

  void _showDeleteConfirm(BuildContext context, HistoryProvider provider) {
    showDialog(
      context: context, 
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle), child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 32)),
              const SizedBox(height: 16),
              const Text("Delete Selected?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              const Text("This action cannot be undone.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel"))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () { Navigator.pop(ctx); provider.deleteSelected(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold)))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}