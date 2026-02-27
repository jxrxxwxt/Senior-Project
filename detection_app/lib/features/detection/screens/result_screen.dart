import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/dialog_utils.dart';
import '../../../core/widgets/custom_button.dart'; // อย่าลืม Import CustomButton
import '../../../data/models/analysis_result.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/history_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../widgets/save_folder_sheet.dart'; // Import ไฟล์ใหม่ที่สร้าง

class ResultScreen extends StatefulWidget {
  final AnalysisResult result;
  final File imageFile;
  const ResultScreen(
      {super.key, required this.result, required this.imageFile});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  // String _selectedFolder = 'General'; <--- ลบบรรทัดนี้ทิ้ง ไม่ต้องใช้ State ตรงนี้แล้ว

  void _onSavePressed() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login to save results")));
      return;
    }

    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter Item Name")));
      return;
    }

    // เปิด Pop-up แบบ Apple Style
    final selectedFolder = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true, // สำคัญมาก เพื่อให้ Sheet ยืดได้เต็มที่
      backgroundColor: Colors.transparent, // ให้เห็นมุมโค้ง
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const SaveFolderSheet(),
      ),
    );

    if (selectedFolder != null && mounted) {
      _saveToApi(selectedFolder);
    }
  }

  void _saveToApi(String folderName) async {
    DialogUtils.showLoading(context);

    try {
      final data = {
        "item_name": _nameCtrl.text,
        "model_used": widget.result.modelUsed,
        "gram_type": widget.result.gramType,
        "shape": widget.result.shape,
        "accuracy": widget.result.accuracy,
        "note": _noteCtrl.text,
        "folder_name": folderName, // ใช้ชื่อ Folder ที่ได้จาก Pop-up
      };

      await Provider.of<HistoryProvider>(context, listen: false)
          .addHistoryItem(data);

      if (mounted) {
        DialogUtils.hideLoading(context);
        DialogUtils.showSuccess(context, "Saved Successfully!");

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (r) => false);
      }
      //   ScaffoldMessenger.of(context)
      //       .showSnackBar(const SnackBar(content: Text("Saved Successfully!")));
      //   Navigator.pushAndRemoveUntil(
      //       context,
      //       MaterialPageRoute(builder: (_) => const DashboardScreen()),
      //       (r) => false);
      // }
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
      appBar: AppBar(title: const Text("Analysis Results")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(widget.imageFile,
                  height: 250, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),

            // Item Name Input
            TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: "Item Name *",
                  hintText: "Enter analysis name",
                  fillColor: Colors.grey[50],
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                )),
            const SizedBox(height: 16),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _infoRow(
                      "Timestamp",
                      DateFormat('EEEE, MMM d, yyyy \nAT h:mm a')
                          .format(widget.result.timestamp)),
                  const Divider(height: 24),
                  _infoRow("Accuracy",
                      "${widget.result.accuracy.toStringAsFixed(1)}%",
                      isHighlight: true),
                  _infoRow("Gram Type", widget.result.gramType),
                  _infoRow("Shape", widget.result.shape),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- ตรงนี้ลบ Dropdown ออกไปแล้ว ---

            // Note Input
            TextField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Note (Optional)",
                  hintText: "Add any observations...",
                  fillColor: Colors.grey[50],
                  filled: true,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                )),

            const SizedBox(height: 24),

            // Save Button
            if (isGuest)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200)),
                child: const Center(
                    child: Text("Sign in to save results",
                        style: TextStyle(color: Colors.brown))),
              )
            else
              CustomButton(
                text: "Save to History",
                onPressed: _onSavePressed, // เปลี่ยนมาเรียกฟังก์ชันเปิด Pop-up
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value,
            textAlign: TextAlign.right,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHighlight ? Colors.green : AppColors.textDark,
                fontSize: isHighlight ? 18 : 14)),
      ]),
    );
  }
}
