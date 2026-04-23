import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/history_item.dart';
import '../../../providers/history_provider.dart';
import '../../detection/widgets/fullscreen_image_viewer.dart';

// ★ 1. เปลี่ยนเป็น StatefulWidget เพื่อจัดการ State การโหลด
class HistoryDetailScreen extends StatefulWidget {
  final HistoryItem item;
  const HistoryDetailScreen({super.key, required this.item});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  HistoryItem? _fullItem;
  bool _isLoadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadFullDetails();
  }

  // ★ 2. ฟังก์ชันไปดึงข้อมูลตัวเต็ม (พร้อมรูป Base64) จาก Provider
  Future<void> _loadFullDetails() async {
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    final fullData = await provider.fetchHistoryDetail(widget.item.id);
    
    if (mounted) {
      setState(() {
        _fullItem = fullData; // เก็บข้อมูลตัวเต็มที่มีรูป
        _isLoadingImage = false; // ปิด Loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    
    String folderDisplayName = "General";
    if (widget.item.folderId != null) {
      try {
        final folder = provider.folders.firstWhere((f) => f.id == widget.item.folderId);
        folderDisplayName = folder.name;
      } catch (e) {
        folderDisplayName = "Unknown";
      }
    }

    // ข้อมูลที่เราจะใช้แสดงผล (ถ้าโหลดตัวเต็มเสร็จใช้ตัวเต็ม ถ้ายังให้ใช้ตัวเดิมไปก่อน)
    final displayItem = _fullItem ?? widget.item;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(widget.item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)), 
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children:[
            // --- Before & After Images ---
            _buildBeforeAfterSection(displayItem),
            const SizedBox(height: 24),

            // -----------------------------------------------------------
            // 2. Model Used Badge
            // -----------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.item.modelUsed.contains("Specimen") ? Colors.orange.withValues(alpha: 0.1) : Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.item.modelUsed.contains("Specimen") ? Colors.orange.withValues(alpha: 0.3) : Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children:[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.item.modelUsed.contains("Specimen") ? Colors.orange : Colors.purple,
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
                      Text(widget.item.modelUsed, style: TextStyle(color: widget.item.modelUsed.contains("Specimen") ? Colors.orange.shade800 : Colors.purple.shade800, fontSize: 18, fontWeight: FontWeight.bold)),
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
                  
                  _detailRow("Date & Time", DateFormat('MMM d, yyyy \nAT h:mm a').format(widget.item.timestamp)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFEDF1F7)),
                  ),
                  _detailRow("Accuracy", "${widget.item.accuracy.toStringAsFixed(1)}%", isHighlight: true),
                  _detailRow("Gram Type", widget.item.gramType),
                  _detailRow("Shape", widget.item.shape),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFEDF1F7)),
                  ),
                  _detailRow("Saved in Folder", folderDisplayName, isFolder: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // -----------------------------------------------------------
            // 4. Note Card
            // -----------------------------------------------------------
            if (widget.item.note != null && widget.item.note!.isNotEmpty)
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
                    const Row(
                      children: [
                        Icon(Icons.edit_note_rounded, size: 22, color: AppColors.textGrey), 
                        SizedBox(width: 8), 
                        Text("Label Note", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 16))
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
                        widget.item.note!,
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
          ? Container(
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

  // --- Before & After Images Section ---
  Widget _buildBeforeAfterSection(HistoryItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Detection Results",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // --- BEFORE ---
            Expanded(
              child: _buildImageCard(
                label: "Before",
                imageBase64: item.originalImageBase64 ?? '',
                isAnnotated: false,
              ),
            ),
            const SizedBox(width: 12),
            // --- AFTER ---
            Expanded(
              child: _buildImageCard(
                label: "After (with Bounding Box)",
                imageBase64: item.annotatedImageBase64 ?? '',
                isAnnotated: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard({
    required String label,
    required String imageBase64,
    required bool isAnnotated,
  }) {
    return Builder(
      builder: (context) {
        // ★ 3. ถ้ากำลังโหลดอยู่ ให้โชว์ Loading ตรงพื้นที่รูปภาพแทน
        if (_isLoadingImage) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: const Color(0xFFF7F9FC),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          );
        }

        // ถ้าโหลดเสร็จแต่ได้ค่าว่างมา (Error จากระบบ)
        if (imageBase64.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: const Color(0xFFF7F9FC),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 32),
                      SizedBox(height: 8),
                      Text("No Image", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
            ],
          );
        }

        final imageBytes = base64Decode(imageBase64);

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FullscreenImageViewer(
                  imageBase64: imageBase64,
                  title: label,
                  isAnnotated: isAnnotated,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      imageBytes,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black.withValues(alpha: 0),
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.zoom_in, color: Colors.white, size: 32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              const Text(
                "Tap to view full size → Save to Gallery",
                style: TextStyle(fontSize: 10, color: AppColors.textGrey),
              ),
            ],
          ),
        );
      },
    );
  }
}