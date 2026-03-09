import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'camera_screen.dart';

class ModelSelectionSheet extends StatelessWidget {
  const ModelSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Select Model", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
          ]),
          const SizedBox(height: 20),
          _modelOption(context, "Specimen Model", "For mixed populations", Icons.science, AppColors.specimenColor, "Specimen"),
          const SizedBox(height: 16),
          _modelOption(context, "Pure Culture Model", "For isolated colonies", Icons.biotech, AppColors.pureCultureColor, "Pure Culture"),
        ],
      ),
    );
  }

  Widget _modelOption(BuildContext context, String title, String sub, IconData icon, Color color, String modelName) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => CameraScreen(modelName: modelName)));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white)),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])
        ]),
      ),
    );
  }
}