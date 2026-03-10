import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/apple_sheet_wrapper.dart';
import '../../../providers/history_provider.dart';
import '../../../core/utils/dialog_utils.dart';

class SaveFolderSheet extends StatefulWidget {
  const SaveFolderSheet({super.key});

  @override
  State<SaveFolderSheet> createState() => _SaveFolderSheetState();
}

class _SaveFolderSheetState extends State<SaveFolderSheet> {
  int? _selectedFolderId; 
  bool _isCreatingNewFolder = false; 
  final TextEditingController _newFolderCtrl = TextEditingController();
  final FocusNode _folderFocusNode = FocusNode();
  
  // เพิ่ม ScrollController เพื่อใช้ควบคุม Scrollbar
  final ScrollController _scrollController = ScrollController();
  
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _newFolderCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _newFolderCtrl.dispose();
    _folderFocusNode.dispose();
    _scrollController.dispose(); // อย่าลืม dispose controller
    super.dispose();
  }

  void _handleSave() async {
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    
    if (_isCreatingNewFolder) {
      String newName = _newFolderCtrl.text.trim();
      if (newName.isEmpty) return;

      DialogUtils.showLoading(context);
      try {
        await provider.createNewFolder(newName);
        final newFolder = provider.folders.firstWhere((f) => f.name == newName);
        
        if (mounted) {
          DialogUtils.hideLoading(context);
          Navigator.pop(context, newFolder.id); 
        }
      } catch (e) {
        if (mounted) {
          DialogUtils.hideLoading(context);
          DialogUtils.showError(context, "Could not create folder. Please try again.");
        }
      }
    } else {
      Navigator.pop(context, _selectedFolderId); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, _) {
        final existingFolders = provider.folders; 
        
        final filteredFolders = existingFolders.where((folder) {
          return folder.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        bool isInputValid = !_isCreatingNewFolder || (_isCreatingNewFolder && _newFolderCtrl.text.trim().isNotEmpty);

        return AppleSheetWrapper(
          child: Padding(
            // ปรับ Padding ด้านขวาให้ลดลงนิดนึง เพื่อแบ่งพื้นที่ให้ Scrollbar
            padding: const EdgeInsets.fromLTRB(24, 0, 16, 0), 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40), 
                    const Text("Save to Folder", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                // ปรับระยะด้านขวาของข้อความให้เท่ากับด้านซ้าย
                const Padding(
                  padding: EdgeInsets.only(right: 8), 
                  child: Text("Choose where to save this analysis", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
                const SizedBox(height: 16),

                // ================= 1. ช่องค้นหา (Fixed) =================
                Padding(
                  padding: const EdgeInsets.only(right: 8), // จัดให้ขอบตรงกับกล่องด้านล่าง
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: "Search folder...",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF7F9FC),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ================= 2. No Folder (Fixed) =================
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildOptionItem(
                    title: "No Folder",
                    icon: Icons.description_outlined,
                    iconColor: AppColors.textGrey,
                    folderId: null, 
                  ),
                ),
                const SizedBox(height: 12),
                
                // ================= 3. Existing Folders (Scrollable with Scrollbar) =================
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  // ★ ครอบด้วย RawScrollbar เพื่อปรับแต่งหน้าตาแถบเลื่อน
                  child: RawScrollbar(
                    controller: _scrollController,
                    thumbVisibility: true, // บังคับให้แสดงตลอดเวลา จะได้รู้ว่าเลื่อนได้
                    thickness: 4.0, // ปรับความบาง (ค่าน้อยยิ่งบาง)
                    radius: const Radius.circular(10), // ปรับความมนของขอบ
                    thumbColor: Colors.grey.withOpacity(0.3), // สีของแถบเลื่อน
                    padding: const EdgeInsets.only(right: 0), // ระยะห่างจากขอบขวา
                    child: SingleChildScrollView(
                      controller: _scrollController, // ต้องใส่ controller ให้ตรงกับ Scrollbar
                      child: Padding(
                        // เว้นระยะขวาเผื่อให้ Scrollbar ไม่ทับกับเนื้อหา
                        padding: const EdgeInsets.only(right: 12), 
                        child: Column(
                          children: [
                            if (filteredFolders.isEmpty && _searchQuery.isNotEmpty)
                               const Padding(
                                 padding: EdgeInsets.symmetric(vertical: 20),
                                 child: Text("No folders match your search.", style: TextStyle(color: Colors.grey)),
                               ),
                            ...filteredFolders.map((folder) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildOptionItem(
                                title: folder.name,
                                icon: Icons.folder_open_rounded,
                                iconColor: const Color(0xFFFF7043),
                                folderId: folder.id, 
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ================= 4. Create New Folder (Fixed) =================
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildNewFolderSection(),
                ),
                
                const SizedBox(height: 32),

                // ================= 5. Buttons (Fixed) =================
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFFEDF1F7)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            foregroundColor: AppColors.textDark,
                          ),
                          child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isInputValid ? _handleSave : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isInputValid ? AppColors.primary : const Color(0xFFFAB06E).withOpacity(0.5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: isInputValid ? 2 : 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            disabledBackgroundColor: const Color(0xFFFAB06E).withOpacity(0.5),
                          ),
                          child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildOptionItem({required String title, required IconData icon, required Color iconColor, required int? folderId}) {
    final isSelected = _selectedFolderId == folderId && !_isCreatingNewFolder;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFolderId = folderId;
          _isCreatingNewFolder = false;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFEDF1F7),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            if (isSelected) BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
            else BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
          ]
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : iconColor, size: 22),
            const SizedBox(width: 16),
            // ใช้ Expanded ครอบ Text เพื่อป้องกันปัญหาข้อความยาวทะลุจอ
            Expanded(
              child: Text(
                title, 
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                  fontSize: 15, 
                  color: isSelected ? AppColors.primary : AppColors.textDark
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // ถ้าชื่อยาวเกินให้แสดงเป็น ...
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewFolderSection() {
    final bool active = _isCreatingNewFolder;

    return InkWell(
      onTap: () {
        if (!active) {
          setState(() {
            _isCreatingNewFolder = true;
            _selectedFolderId = -2; 
          });
          _folderFocusNode.requestFocus();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: active ? Colors.white : const Color(0xFFFBF5FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppColors.purpleIcon : const Color(0xFFE8D0FF),
            width: active ? 1.5 : 1,
          ),
          boxShadow: [
            if (active) BoxShadow(color: AppColors.purpleIcon.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
          ]
        ),
        child: active 
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.add_box_rounded, color: AppColors.purpleIcon, size: 22),
                    SizedBox(width: 16),
                    Text("New Folder", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.purpleIcon, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newFolderCtrl,
                  focusNode: _folderFocusNode,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: "Enter folder name",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.normal),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 38),
                    border: InputBorder.none,
                  ),
                ),
              ],
            )
          : const Row(
              children: [
                Icon(Icons.add_box_rounded, color: AppColors.purpleIcon, size: 22),
                SizedBox(width: 16),
                Text("Create New Folder", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.purpleIcon, fontSize: 15)),
              ],
            ),
      ),
    );
  }
}