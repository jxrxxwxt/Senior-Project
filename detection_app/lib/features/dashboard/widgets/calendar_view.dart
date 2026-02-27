import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.week,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle),
            ),
          ),
          const Divider(height: 20),
          if (_selectedDay != null)
            const Text("Analyses: 5   |   Avg. Accuracy: 91.4%", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark))
        ],
      ),
    );
  }
}