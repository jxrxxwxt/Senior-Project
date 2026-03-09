import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/dialog_utils.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/models/analysis_result.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/history_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../widgets/save_folder_sheet.dart'; 

class ResultScreen extends StatefulWidget {
  final AnalysisResult result;
  final File imageFile;
  const ResultScreen({super.key, required this.result, required this.imageFile});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  void _onSavePressed() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isGuest) {
      DialogUtils.showError(context, "Please login to save your analysis results.");
      return;
    }

    if (_nameCtrl.text.trim().isEmpty) {
      DialogUtils.showError(context, "Please enter an Item Name before saving.");
      return;
    }

    // เปิด Pop-up แบบ Apple Style เพื่อเลือกโฟลเดอร์
    // คืนค่ากลับมาเป็น int? (Folder ID)
    final selectedFolderId = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const SaveFolderSheet(),
      ),
    );

    // ทำการบันทึกถ้ามีการเลือกโฟลเดอร์หรือเลือก No Folder (null)
    // หมายเหตุ: กรณีที่ User กดปิด BottomSheet ไปเฉยๆ selectedFolderId จะเป็น null ด้วย
    // เพื่อความลื่นไหล เราจะอนุญาตให้เซฟลง General (null) ได้เลย
    if (mounted) {
      _saveToApi(selectedFolderId);
    }
  }

  void _saveToApi(int? folderId) async {
    DialogUtils.showLoading(context);

    try {
      final data = {
        "item_name": _nameCtrl.text.trim(),
        "model_used": widget.result.modelUsed,
        "gram_type": widget.result.gramType,
        "shape": widget.result.shape,
        "accuracy": widget.result.accuracy,
        "note": _noteCtrl.text.trim(),
        "folder_id": folderId, // ★ เปลี่ยนเป็นส่ง folder_id แทนชื่อโฟลเดอร์
      };

      await Provider.of<HistoryProvider>(context, listen: false).addHistoryItem(data);

      if (mounted) {
        DialogUtils.hideLoading(context); // ปิด Loading
        DialogUtils.showSuccess(context, "Saved Successfully!"); // โชว์ Toast ด้านบน

        // กลับหน้าแรก
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (r) => false);
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.hideLoading(context);
        DialogUtils.showError(context, "Failed to save: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = Provider.of<AuthProvider>(context).isGuest;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Analysis Results", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children:[
            // --- Image Preview ---
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                widget.imageFile,
                height: 250, 
                width: double.infinity, 
                fit: BoxFit.cover
              ),
            ),
            const SizedBox(height: 24),

            // --- Item Name Input ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                const Text("Item Name *", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: "Enter analysis name",
                    hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                    fillColor: const Color(0xFFF7F9FC), // สี Apple Input
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  )
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Info Card ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDF1F7)),
                  boxShadow:[
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                  ]
              ),
              child: Column(
                children:[
                  _infoRow("Timestamp", DateFormat('EEEE, MMM d, yyyy \nAT h:mm a').format(widget.result.timestamp)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: Color(0xFFEDF1F7)),
                  ),
                  _infoRow("Accuracy", "${widget.result.accuracy.toStringAsFixed(1)}%", isHighlight: true),
                  _infoRow("Gram Type", widget.result.gramType),
                  _infoRow("Shape", widget.result.shape),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Note Input ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                const Text("Note (Optional)", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Add any observations...",
                    hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                    fillColor: const Color(0xFFF7F9FC),
                    filled: true,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  )
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- Save Button ---
            if (isGuest)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
                child: const Center(
                  child: Text("Sign in to save results to history", style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold))
                ),
              )
            else
              CustomButton(
                text: "Save to History",
                onPressed: _onSavePressed,
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget ---
  Widget _infoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children:[
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.green : AppColors.textDark,
              fontSize: isHighlight ? 18 : 14
            ),
          ),
      ]),
    );
  }
}