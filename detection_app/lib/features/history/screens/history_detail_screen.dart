import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/history_item.dart';
import '../../../providers/history_provider.dart';

class HistoryDetailScreen extends StatelessWidget {
  final HistoryItem item;
  const HistoryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // ใช้ Provider เพื่อดึงชื่อโฟลเดอร์จาก folderId ของ item
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    
    // หารายชื่อโฟลเดอร์จาก ID, ถ้าไม่เจอหรือเป็น null ให้แสดงคำว่า "General"
    String folderDisplayName = "General";
    if (item.folderId != null) {
      try {
        final folder = provider.folders.firstWhere((f) => f.id == item.folderId);
        folderDisplayName = folder.name;
      } catch (e) {
        folderDisplayName = "Unknown";
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // พื้นหลังสีเทาอ่อนคลีนๆ
      appBar: AppBar(
        title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)), 
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children:[
            // -----------------------------------------------------------
            // 1. Image Placeholder 
            // -----------------------------------------------------------
            // (ตอนนี้ใส่ Placeholder รอเฟสรูปภาพ)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 250, 
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC), // สีเทาอ่อน
                  border: Border.all(color: const Color(0xFFEDF1F7)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const[
                    Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 12),
                    Text("Original Image", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // -----------------------------------------------------------
            // 2. Model Used Badge
            // -----------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: item.modelUsed.contains("Specimen") ? Colors.orange.withValues(alpha: 0.1) : Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: item.modelUsed.contains("Specimen") ? Colors.orange.withValues(alpha: 0.3) : Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children:[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.modelUsed.contains("Specimen") ? Colors.orange : Colors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.science_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      const Text("Model Used", style: TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(item.modelUsed, style: TextStyle(color: item.modelUsed.contains("Specimen") ? Colors.orange.shade800 : Colors.purple.shade800, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // -----------------------------------------------------------
            // 3. Analysis Details Card
            // -----------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDF1F7)),
                boxShadow:[
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  const Text("Analysis Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 20),
                  
                  _detailRow("Date & Time", DateFormat('MMM d, yyyy \nAT h:mm a').format(item.timestamp)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFEDF1F7)),
                  ),
                  _detailRow("Accuracy", "${item.accuracy.toStringAsFixed(1)}%", isHighlight: true),
                  _detailRow("Gram Type", item.gramType),
                  _detailRow("Shape", item.shape),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFEDF1F7)),
                  ),
                  _detailRow("Saved in Folder", folderDisplayName, isFolder: true), // ★ ใช้ชื่อโฟลเดอร์ที่แปลงมาจาก ID
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // -----------------------------------------------------------
            // 4. Note Card
            // -----------------------------------------------------------
            if (item.note != null && item.note!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDF1F7)),
                  boxShadow:[
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Row(
                      children: const[
                        Icon(Icons.edit_note_rounded, size: 22, color: AppColors.textGrey), 
                        SizedBox(width: 8), 
                        Text("Observations Note", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16))
                      ]
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.note!,
                        style: const TextStyle(height: 1.5, color: AppColors.textDark, fontSize: 15),
                      ),
                    ),
                  ]
                ),
              ),
              
              const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Helper Widget สำหรับแถวรายละเอียด ---
  Widget _detailRow(String label, String value, {bool isHighlight = false, bool isFolder = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
          
          isFolder 
          ? Container( // ถ้าเป็นโฟลเดอร์ ให้มีพื้นหลังสีส้มอ่อนๆ ล้อมรอบ
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children:[
                  const Icon(Icons.folder, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                ],
              ),
            )
          : Text(
              value, 
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: isHighlight ? 18 : 15, 
                color: isHighlight ? Colors.green : AppColors.textDark
              )
            ),
        ],
      ),
    );
  }
}