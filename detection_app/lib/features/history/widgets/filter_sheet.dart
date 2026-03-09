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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 34), // เว้นระยะด้านล่างเผื่อขอบจอ
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          // Handle (ขีดด้านบน)
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
            children:[
              const Text("Filter Results", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey), 
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            ],
          ),
          const SizedBox(height: 4),
          const Text("Refine your search with these filters", style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
          const SizedBox(height: 24),

          // Filters
          _buildCustomDropdown("Date Range", _date,['All Time', 'Today', 'This Week', 'This Month'], (val) => setState(() => _date = val)),
          const SizedBox(height: 16),
          _buildCustomDropdown("Gram Type", _gram, ['All Types', 'Gram-positive', 'Gram-negative', 'Yeast'], (val) => setState(() => _gram = val)),
          const SizedBox(height: 16),
          _buildCustomDropdown("Bacterial Shape", _shape,['All Shapes', 'Cocci', 'Bacilli', 'Spirilla'], (val) => setState(() => _shape = val)),

          const SizedBox(height: 32),

          // Buttons
          Row(
            children:[
              Expanded(
                // ★ บังคับความสูงให้เท่า CustomButton
                child: SizedBox(
                  height: 56, 
                  child: OutlinedButton(
                    onPressed: () {
                       Provider.of<HistoryProvider>(context, listen: false).resetFilters();
                       Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // ★ บังคับขอบมนให้เท่ากัน
                      foregroundColor: AppColors.textDark,
                      elevation: 0,
                    ),
                    child: const Text("Reset", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                // ★ บังคับความสูงให้เท่ากับ Reset
                child: SizedBox(
                  height: 56,
                  child: CustomButton(
                    text: "Apply",
                    onPressed: () {
                      Provider.of<HistoryProvider>(context, listen: false).setFilters(date: _date, gram: _gram, shape: _shape);
                      Navigator.pop(context);
                    },
                  ),
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
      children:[
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC), // สี Apple Grey
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey),
              style: const TextStyle(color: AppColors.textDark, fontSize: 15),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => onChanged(val!),
            ),
          ),
        ),
      ],
    );
  }
}