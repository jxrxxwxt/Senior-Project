import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../providers/history_provider.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  // Local State for Filter Selection
  String _date = 'All Time';
  String _gram = 'All Types';
  String _shape = 'All Shapes';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Filter Results", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context))
            ],
          ),
          const Text("Refine your search with these filters", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          // Filters
          _buildCustomDropdown("Date Range", _date, ['All Time', 'Today', 'This Week', 'This Month'], (val) => setState(() => _date = val)),
          const SizedBox(height: 16),
          _buildCustomDropdown("Gram Type", _gram, ['All Types', 'Gram-positive', 'Gram-negative', 'Yeast'], (val) => setState(() => _gram = val)),
          const SizedBox(height: 16),
          _buildCustomDropdown("Bacterial Shape", _shape, ['All Shapes', 'Cocci', 'Bacilli', 'Spirilla'], (val) => setState(() => _shape = val)),

          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                     Provider.of<HistoryProvider>(context, listen: false).resetFilters();
                     Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: AppColors.textDark,
                  ),
                  child: const Text("Reset"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: "Apply",
                  onPressed: () {
                    Provider.of<HistoryProvider>(context, listen: false).setFilters(date: _date, gram: _gram, shape: _shape);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCustomDropdown(String label, String value, List<String> items, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              style: const TextStyle(color: AppColors.textDark, fontSize: 16, fontFamily: 'Inter'),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => onChanged(val!),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}