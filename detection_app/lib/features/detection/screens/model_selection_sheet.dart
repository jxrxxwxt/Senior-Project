import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import 'result_screen.dart';

class ModelSelectionSheet extends StatelessWidget {
  const ModelSelectionSheet({super.key});

  Future<void> _pickImage(BuildContext context, String modelName, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source);
    
    if (photo != null && context.mounted) {
      Navigator.pop(context); // Close BottomSheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imageFile: File(photo.path),
            modelName: modelName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 40),
      decoration: const BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              const Text("Select Analysis Model", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
            ]
          ),
          const SizedBox(height: 24),
          _modelOption(context, "Specimen Model", "For mixed populations (Sputum, Urine, etc.)", Icons.science, AppColors.specimenColor, "Specimen"),
          const SizedBox(height: 16),
          _modelOption(context, "Pure Culture Model", "For isolated colonies (Agar plate)", Icons.biotech, AppColors.pureCultureColor, "Pure Culture"),
        ],
      ),
    );
  }

  Widget _modelOption(BuildContext context, String title, String sub, IconData icon, Color color, String modelName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: color.withValues(alpha: 0.3))
      ),
      child: Column(
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12), 
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), 
              child: Icon(icon, color: Colors.white)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            )
          ]),
          const SizedBox(height: 16),
          Row(
            children: [
              // Button 1: Camera
              Expanded(
                child: _actionButton(
                  context: context,
                  label: "Take Photo",
                  icon: Icons.camera_alt_rounded,
                  color: color,
                  isPrimary: false, // Outlined look
                  onPressed: () => _pickImage(context, modelName, ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              // Button 2: Gallery
              Expanded(
                child: _actionButton(
                  context: context,
                  label: "Gallery",
                  icon: Icons.photo_library_rounded,
                  color: color,
                  isPrimary: true, // Filled look
                  onPressed: () => _pickImage(context, modelName, ImageSource.gallery),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary ? Colors.white : color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}