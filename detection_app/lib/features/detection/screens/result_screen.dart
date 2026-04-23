import 'dart:io';
import 'dart:convert';
import 'dart:ui';
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
import '../widgets/fullscreen_image_viewer.dart'; 
import '../../../data/repositories/detection_repository.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  final String modelName;
  const ResultScreen({super.key, required this.imageFile, required this.modelName});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  AnalysisResult? _analysisResult;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  void _startAnalysis() async {
    try {
      File compressedImage = await _compressAndResizeImage(widget.imageFile);

      final repo = DetectionRepository();
      final result = await repo.analyzeImage(compressedImage, widget.modelName);
      
      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<File> _compressAndResizeImage(File file) async {
    try {
      final originalSize = await file.length();
      debugPrint('>>> Original size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB');

      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: 640,
        minHeight: 640,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final compressedSize = await result.length();
        debugPrint('>>> Compressed size: ${(compressedSize / 1024).toStringAsFixed(2)} KB');
        return File(result.path);
      }
      return file;
    } catch (e) {
      debugPrint("Image Compression Error: $e");
      return file;
    }
  }

  void _onSavePressed() async {
    if (_analysisResult == null) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isGuest) {
      DialogUtils.showError(context, "Please login to save your analysis results.");
      return;
    }

    if (_nameCtrl.text.trim().isEmpty) {
      DialogUtils.showError(context, "Please enter an Item Name before saving.");
      return;
    }

    final selectedFolderId = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const SaveFolderSheet(),
      ),
    );

    if (mounted) {
      _saveToApi(selectedFolderId);
    }
  }

  void _saveToApi(int? folderId) async {
    if (_analysisResult == null) return;
    DialogUtils.showLoading(context);

    try {
      final result = _analysisResult!;
      final data = {
        "item_name": _nameCtrl.text.trim(),
        "model_used": result.modelUsed,
        "gram_type": result.gramType,
        "shape": result.shape,
        "accuracy": result.accuracy,
        "note": _noteCtrl.text.trim(),
        "folder_id": folderId,
        "original_image_base64": result.originalImageBase64,
        "annotated_image_base64": result.annotatedImageBase64,
      };

      await Provider.of<HistoryProvider>(context, listen: false).addHistoryItem(data);

      if (mounted) {
        DialogUtils.hideLoading(context); 
        DialogUtils.showSuccess(context, "Saved Successfully!");

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
        title: const Text("Analysis Results",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        const Text(
                          "Analysis Failed",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textGrey),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: "Try Again",
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _startAnalysis();
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildBeforeAfterSection(),
                      const SizedBox(height: 24),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Item Name *",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                  fontSize: 13)),
                          const SizedBox(height: 8),
                          TextField(
                              controller: _nameCtrl,
                              decoration: InputDecoration(
                                hintText: "Enter analysis name",
                                hintStyle: const TextStyle(
                                    color: AppColors.textGrey, fontSize: 14),
                                fillColor:
                                    const Color(0xFFF7F9FC),
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none),
                              )),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEDF1F7)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ]),
                        child: Column(
                          children: [
                            _infoRow(
                                "Timestamp",
                                _analysisResult != null
                                    ? DateFormat('EEEE, MMM d, yyyy \nAT h:mm a')
                                        .format(_analysisResult!.timestamp)
                                    : "Predicting..."),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child:
                                  Divider(height: 1, color: Color(0xFFEDF1F7)),
                            ),
                            _infoRow(
                                "Accuracy",
                                _analysisResult != null
                                    ? "${_analysisResult!.accuracy.toStringAsFixed(1)}%"
                                    : "--%",
                                isHighlight: true),
                            _infoRow("Gram Type",
                                _analysisResult?.gramType ?? "Scanning..."),
                            _infoRow("Shape",
                                _analysisResult?.shape ?? "Scanning..."),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Label Note (Optional)",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                  fontSize: 13)),
                          const SizedBox(height: 8),
                          TextField(
                              controller: _noteCtrl,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Add any observations...",
                                hintStyle: const TextStyle(
                                    color: AppColors.textGrey, fontSize: 14),
                                fillColor: const Color(0xFFF7F9FC),
                                filled: true,
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none),
                              )),
                        ],
                      ),

                      const SizedBox(height: 32),

                      if (isGuest)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3))),
                          child: const Center(
                              child: Text("Sign in to save results to history",
                                  style: TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold))),
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
          if (_isLoading)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.5),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                              color: AppColors.primary),
                          SizedBox(height: 16),
                          Text(
                            "Analyzing image...",
                            style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBeforeAfterSection() {
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
            Expanded(
              child: _analysisResult != null
                  ? _buildImageCard(
                      label: "Before",
                      imageBase64: _analysisResult!.originalImageBase64,
                      isAnnotated: false,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        widget.imageFile,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _analysisResult != null
                  ? _buildImageCard(
                      label: "After (with Bounding Box)",
                      imageBase64: _analysisResult!.annotatedImageBase64,
                      isAnnotated: true,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children:[
                          Image.file(
                            widget.imageFile,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            height: 180,
                            color: Colors.black.withValues(alpha: 0.1),
                            child: const Center(
                              child: Text(
                                "Processing...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                child: Column(
                  children: [
                    Image.memory(
                      imageBytes,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ],
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
                      child: Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
          const SizedBox(height: 4),
          const Text(
            "Tap to view full size → Save to Gallery",
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

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