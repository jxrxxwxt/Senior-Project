import 'package:detection_app/data/models/folder_model.dart';
import 'package:detection_app/features/history/widgets/filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/history_item.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/history_provider.dart';
import '../../auth/screens/login_screen.dart';
import 'folder_detail_screen.dart';
import 'history_detail_screen.dart';
import '../../../core/utils/dialog_utils.dart';

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

    // 1. Guest Mode View
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
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200, shape: BoxShape.circle),
                      child: const Icon(Icons.lock_outline,
                          size: 20, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Guest User",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textDark)),
                        Text("Limited Access",
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle),
                        child: Icon(Icons.lock_outline_rounded,
                            size: 60, color: Colors.grey.shade400)),
                    const SizedBox(height: 24),
                    const Text("History Not Available",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                            "To access dashboard features, statistics, and history, please sign in with your account.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, height: 1.5))),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF37E12),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.login_rounded, size: 20),
                        label: const Text("Sign In to Continue",
                            style: TextStyle(fontWeight: FontWeight.bold)))
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      );
    }

    // 2. Member Mode View
    return Consumer<HistoryProvider>(
      builder: (context, provider, _) {
        final totalSelected =
            provider.selectedIds.length + provider.selectedFolderIds.length;
        final isAllSelected =
            (provider.selectedIds.length == provider.items.length) &&
                (provider.selectedFolderIds.length == provider.folders.length);

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            title: const Text("History",
                style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            actions: provider.isSelectionMode
                ? [
                    TextButton(
                      onPressed: () => provider.selectAll(),
                      child: Text(isAllSelected ? "Deselect All" : "Select All",
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                    TextButton(
                      onPressed: () => provider.toggleSelectionMode(),
                      child: const Text("Cancel",
                          style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                  ]
                : [
                    TextButton.icon(
                      onPressed: () => provider.toggleSelectionMode(),
                      icon: const Icon(Icons.check_box_outlined,
                          size: 18, color: AppColors.textGrey),
                      label: const Text("Select",
                          style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                  ],
          ),
          body: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        // 1. เปลี่ยน Container เป็น SizedBox
                        height: 48,
                        // ลบ decoration ของ Container ออกไปเลย
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => provider.setSearchQuery(v),
                          decoration: InputDecoration(
                            // 2. เอาคำว่า const ออก
                            hintText: "Search name, folder or note...",
                            hintStyle: const TextStyle(
                                color: AppColors.textGrey, fontSize: 14),
                            prefixIcon: const Icon(Icons.search,
                                color: AppColors.textGrey),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),

                            // 3. ใส่สีพื้นหลังตรงนี้
                            filled: true,
                            fillColor: const Color(0xFFF7F9FC),

                            // 4. บังคับขอบมนในทุกสถานะ (ปกติ, ตอนกด, ตอนใช้งานอยู่)
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 1.5)),
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
                          builder: (_) => const FilterSheet()),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEDF1F7))),
                        child: const Icon(Icons.tune_rounded,
                            color: AppColors.textDark, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary))
                    : ListView(
                        padding: const EdgeInsets.only(top: 8, bottom: 40),
                        children: [
                          if (provider.isSelectionMode)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("$totalSelected item(s) selected",
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  if (totalSelected > 0)
                                    InkWell(
                                      onTap: () =>
                                          _showDeleteConfirm(context, provider),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline,
                                                color: Colors.red, size: 18),
                                            SizedBox(width: 4),
                                            Text("Delete",
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          if (provider.folders.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text("Folders",
                                  style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ),
                            GridView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: provider.folders.length,
                              itemBuilder: (context, index) => _buildFolderCard(
                                  provider.folders[index], provider),
                            ),
                            const SizedBox(height: 24),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text("All Items",
                                style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                          if (provider.items.isEmpty)
                            const Center(
                                child: Padding(
                                    padding: EdgeInsets.only(top: 40),
                                    child: Text("No items found",
                                        style: TextStyle(color: Colors.grey))))
                          else
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: provider.items
                                    .map((item) =>
                                        _buildHistoryItem(item, provider))
                                    .toList(),
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

  Widget _buildFolderCard(FolderModel folder, HistoryProvider provider) {
    final isSelected = provider.selectedFolderIds.contains(folder.id);
    return InkWell(
      onTap: () {
        if (provider.isSelectionMode) {
          provider.toggleFolderSelection(folder.id);
        } else {
          // ★ แก้ไขตรงนี้: ส่ง ID ไปด้วย
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => FolderDetailScreen(
                      folderId: folder.id, folderName: folder.name)));
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: isSelected ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ]),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFBE9E7),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.folder_rounded,
                            color: Color(0xFFFF7043), size: 24)),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(folder.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textDark)),
                          Text("${folder.itemCount} items",
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textGrey))
                        ])
                  ]),
            ),
            if (provider.isSelectionMode)
              Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade400,
                              width: 1.5)),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 14)
                          : null))
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(HistoryItem item, HistoryProvider provider) {
    final isSelected = provider.selectedIds.contains(item.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: isSelected ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => provider.isSelectionMode
            ? provider.toggleItemSelection(item.id)
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => HistoryDetailScreen(item: item))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            if (provider.isSelectionMode)
              Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade400,
                              width: 1.5)),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null)),
            Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.description_outlined,
                    color: AppColors.textDark, size: 24)),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(item.itemName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(
                      "${DateFormat('dd/MM/yyyy').format(item.timestamp)} • ${item.accuracy}% • ${item.gramType}",
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textGrey))
                ])),
            if (!provider.isSelectionMode)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textGrey, size: 20),
          ]),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, HistoryProvider provider) {
    int totalSelected =
        provider.selectedIds.length + provider.selectedFolderIds.length;

    // เรียกใช้ Dialog จากไฟล์ utils ที่มีธีมสวยงามตรงปก
    DialogUtils.showConfirmDialog(
      context,
      title: "Delete Items?",
      message:
          "Are you sure you want to delete $totalSelected items?\nThis action cannot be undone.",
      confirmText: "Delete",
      onConfirm: () => provider.deleteSelected(),
    );
  }
}
