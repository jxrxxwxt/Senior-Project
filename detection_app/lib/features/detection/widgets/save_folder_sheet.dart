import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/apple_sheet_wrapper.dart';
import '../../../providers/history_provider.dart';
import '../../../core/utils/dialog_utils.dart'; // อย่าลืม Import DialogUtils เพื่อโชว์ Loading

class SaveFolderSheet extends StatefulWidget {
  const SaveFolderSheet({super.key});

  @override
  State<SaveFolderSheet> createState() => _SaveFolderSheetState();
}

class _SaveFolderSheetState extends State<SaveFolderSheet> {
  int? _selectedFolderId; // เปลี่ยนเป็นเก็บ ID แทนการเก็บชื่อโฟลเดอร์
  bool _isCreatingNewFolder = false; 
  final TextEditingController _newFolderCtrl = TextEditingController();
  final FocusNode _folderFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // ให้ระบบเช็คและอัปเดตสีปุ่มเมื่อมีการพิมพ์
    _newFolderCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _newFolderCtrl.dispose();
    _folderFocusNode.dispose();
    super.dispose();
  }

  // --- ฟังก์ชันหลักเมื่อกดปุ่ม Save ---
  void _handleSave() async {
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    
    // 1. ถ้า User อยู่ในโหมด "สร้างโฟลเดอร์ใหม่"
    if (_isCreatingNewFolder) {
      String newName = _newFolderCtrl.text.trim();
      if (newName.isEmpty) return;

      DialogUtils.showLoading(context);
      try {
        // สั่งสร้าง Folder ในฐานข้อมูล
        await provider.createNewFolder(newName);
        
        // ค้นหา ID ของโฟลเดอร์ที่เพิ่งสร้าง
        final newFolder = provider.folders.firstWhere((f) => f.name == newName);
        
        if (mounted) {
          DialogUtils.hideLoading(context);
          // ปิด Sheet และส่ง ID กลับไปให้หน้า ResultScreen
          Navigator.pop(context, newFolder.id); 
        }
      } catch (e) {
        if (mounted) {
          DialogUtils.hideLoading(context);
          DialogUtils.showError(context, "Could not create folder. Please try again.");
        }
      }
    } 
    // 2. ถ้า User เลือก "โฟลเดอร์ที่มีอยู่แล้ว" หรือ "No Folder"
    else {
      Navigator.pop(context, _selectedFolderId); // ส่ง ID กลับไป (null = No Folder)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, provider, _) {
        final existingFolders = provider.folders; // ดึง FolderModel จริงๆ จาก Provider

        // ปุ่ม Save จะกดได้เมื่อ (1) ไม่ได้สร้างโฟลเดอร์ใหม่ หรือ (2) กำลังสร้างแต่พิมพ์ชื่อแล้ว
        bool isInputValid = !_isCreatingNewFolder || (_isCreatingNewFolder && _newFolderCtrl.text.trim().isNotEmpty);

        return AppleSheetWrapper(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children:[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    const SizedBox(width: 40), 
                    const Text("Save to Folder", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const Text("Choose where to save this analysis", style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 24),

                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: SingleChildScrollView(
                    child: Column(
                      children:[
                        // 1. No Folder (ส่งค่า null)
                        _buildOptionItem(
                          title: "No Folder",
                          icon: Icons.description_outlined,
                          iconColor: AppColors.textGrey,
                          folderId: null, 
                        ),
                        const SizedBox(height: 12),
                        
                        // 2. Existing Folders
                        ...existingFolders.map((folder) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildOptionItem(
                            title: folder.name,
                            icon: Icons.folder_open_rounded,
                            iconColor: const Color(0xFFFF7043),
                            folderId: folder.id, // ใช้ ID อ้างอิง
                          ),
                        )),

                        // 3. Create New Folder Section
                        _buildNewFolderSection(),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                Row(
                  children:[
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
                          backgroundColor: isInputValid ? AppColors.primary : const Color(0xFFFAB06E).withValues(alpha: 0.5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: isInputValid ? 2 : 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          disabledBackgroundColor: const Color(0xFFFAB06E).withValues(alpha: 0.5),
                        ),
                        child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
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
          boxShadow:[
            if (isSelected) BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))
            else BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))
          ]
        ),
        child: Row(
          children:[
            Icon(icon, color: isSelected ? AppColors.primary : iconColor, size: 22),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
              fontSize: 15, 
              color: isSelected ? AppColors.primary : AppColors.textDark
            )),
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
            _selectedFolderId = -2; // ตั้งค่า ID หลอกๆ เพื่อไม่ให้ไปซ้ำกับอันที่มีอยู่
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
          boxShadow:[
            if (active) BoxShadow(color: AppColors.purpleIcon.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))
          ]
        ),
        child: active 
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children:[
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
              children:[
                Icon(Icons.add_box_rounded, color: AppColors.purpleIcon, size: 22),
                SizedBox(width: 16),
                Text("Create New Folder", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.purpleIcon, fontSize: 15)),
              ],
            ),
      ),
    );
  }
}