import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/history_item.dart';
import '../../../providers/history_provider.dart';
import 'history_detail_screen.dart';
import 'history_list_screen.dart'; // เพื่อเรียกใช้ FilterSheet

class FolderDetailScreen extends StatefulWidget {
  final String folderName;
  const FolderDetailScreen({super.key, required this.folderName});

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    // เมื่อเข้าหน้านี้ ให้เอาค่า Search เดิมใน Provider มาใส่ในช่องพิมพ์ (ถ้ามี)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HistoryProvider>(context, listen: false);
      // หากต้องการให้เริ่มหน้าด้วยค่าว่าง ให้ reset search ก่อนได้ที่นี่
      // provider.setSearchQuery(""); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, _) {
        // ★ ดึงข้อมูลจาก provider.items (ซึ่งถูก Filter/Search มาจาก Provider แล้ว)
        // แล้วนำมาคัดเฉพาะรายการที่อยู่ในโฟลเดอร์นี้
        final displayItems = provider.items.where((item) {
          final itemFolder = item.folderName ?? "General";
          return itemFolder == widget.folderName;
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
                fontSize: 24 
              )
            ),
            actions:[
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isSelectionMode = !_isSelectionMode;
                    _selectedIds.clear();
                  });
                },
                icon: Icon(
                  _isSelectionMode ? Icons.close : Icons.check_box_outlined, 
                  size: 18, 
                  color: _isSelectionMode ? Colors.red : AppColors.textGrey
                ),
                label: Text(
                  _isSelectionMode ? "Cancel" : "Select", 
                  style: TextStyle(
                    color: _isSelectionMode ? Colors.red : AppColors.textGrey, 
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
                          // ★ อัปเดตการค้นหาไปที่ Provider ทันทีเพื่อให้กรองรายการแบบ Real-time
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
                        // ★ เปิดแผ่น Filter ขึ้นมาเพื่อให้ User เลือกเงื่อนไข
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const FilterSheet(), // เรียกใช้ตัวเดียวกับหน้า History หลัก
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 48, width: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEDF1F7)),
                        ),
                        child: const Icon(Icons.filter_list, color: AppColors.textDark, size: 20),
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
                    Text(
                      widget.folderName,
                      style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // -------------------------------------------------------
              // 3. Section Header
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
                    if (_isSelectionMode && _selectedIds.isNotEmpty)
                       GestureDetector(
                         onTap: () async {
                           // แสดงการยืนยันการลบแบบเดียวกับหน้าหลัก (ใช้ Logic ลบจาก Provider)
                           for (var id in _selectedIds) {
                             provider.toggleItemSelection(id); // เลือกรายการที่จะลบใน Provider
                           }
                           await provider.deleteSelectedItems(); // ยิง API ลบ
                           setState(() {
                             _isSelectionMode = false;
                             _selectedIds.clear();
                           });
                         },
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
                          return _buildItemCard(context, item);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(BuildContext context, HistoryItem item) {
    final isSelected = _selectedIds.contains(item.id);
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
            if (_isSelectionMode) {
              setState(() {
                if (isSelected) _selectedIds.remove(item.id);
                else _selectedIds.add(item.id);
              });
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
                if (_isSelectionMode)
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
                
                if (!_isSelectionMode)
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}