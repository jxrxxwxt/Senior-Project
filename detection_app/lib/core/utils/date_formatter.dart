import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFullDate(DateTime date) {
    // Ex: Tuesday, February 3, 2026 at 12:14 PM
    return DateFormat('EEEE, MMMM d, yyyy at h:mm a').format(date);
  }

  static String formatShortDate(DateTime date) {
    // Ex: Feb 3, 2026
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    // Ex: 12:14 PM
    return DateFormat('h:mm a').format(date);
  }
}