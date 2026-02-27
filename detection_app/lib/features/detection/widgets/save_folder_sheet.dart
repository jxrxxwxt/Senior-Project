import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/apple_sheet_wrapper.dart';
import '../../../providers/history_provider.dart';

class SaveFolderSheet extends StatefulWidget {
  const SaveFolderSheet({super.key});

  @override
  State<SaveFolderSheet> createState() => _SaveFolderSheetState();
}

class _SaveFolderSheetState extends State<SaveFolderSheet> {
  String _selectedFolder = 'General'; // Default
  bool _isCreatingNewFolder = false; 
  final TextEditingController _newFolderCtrl = TextEditingController();
  final FocusNode _folderFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // เพิ่ม Listener เพื่อให้ปุ่มเปลี่ยนสีทันทีที่เริ่มพิมพ์ชื่อโฟลเดอร์ใหม่
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

  void _handleSave() {
    String folderToSave = _selectedFolder;
    
    if (_isCreatingNewFolder) {
      if (_newFolderCtrl.text.trim().isEmpty) return; // กดเซฟไม่ได้ถ้าชื่อว่าง
      folderToSave = _newFolderCtrl.text.trim();
    }

    Navigator.pop(context, folderToSave);
  }

  @override
  Widget build(BuildContext context) {
    final existingFolders = Provider.of<HistoryProvider>(context, listen: false)
        .getUniqueFolders()
        .where((f) => f != 'General')
        .toList();

    // ★ Check if button should be active (Vibrant Orange)
    bool isInputValid = !_isCreatingNewFolder || (_isCreatingNewFolder && _newFolderCtrl.text.trim().isNotEmpty);

    return AppleSheetWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
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
            const Text("Choose where to save this analysis", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),

            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildOptionItem(
                      title: "No Folder",
                      icon: Icons.description_outlined,
                      iconColor: AppColors.textGrey,
                      value: "General",
                    ),
                    const SizedBox(height: 12),
                    
                    ...existingFolders.map((folder) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptionItem(
                        title: folder,
                        icon: Icons.folder_open_rounded,
                        iconColor: const Color(0xFFFF7043),
                        value: folder,
                      ),
                    )),

                    _buildNewFolderSection(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),

            Row(
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
                    onPressed: isInputValid ? _handleSave : null, // ปิดการกดถ้า Input ไม่ผ่าน
                    style: ElevatedButton.styleFrom(
                      // ★ ปรับสีตรงนี้: ถ้าเลือกแล้วใช้ AppColors.primary (ส้มเข้ม) ถ้ายังไม่เลือกใช้สีจาง
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
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({required String title, required IconData icon, required Color iconColor, required String value}) {
    final isSelected = _selectedFolder == value && !_isCreatingNewFolder;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFolder = value;
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
          setState(() => _isCreatingNewFolder = true);
          _folderFocusNode.requestFocus();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: active ? 12 : 16),
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
                Row(
                  children: [
                    const Icon(Icons.add_box_rounded, color: AppColors.purpleIcon, size: 22),
                    const SizedBox(width: 16),
                    Text("New Folder", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.purpleIcon, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _newFolderCtrl,
                  focusNode: _folderFocusNode,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  autofocus: true,
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