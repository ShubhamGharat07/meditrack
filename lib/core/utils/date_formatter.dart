import 'package:intl/intl.dart';

class DateFormatter {
  // 15 Jan 2026
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // 15 Jan 2026, 8:00 PM
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  // 8:00 PM
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  // Monday, 15 Jan
  static String formatDayDate(DateTime date) {
    return DateFormat('EEEE, dd MMM').format(date);
  }

  // Kitne din pehle — "2 days ago"
  static String timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  // Today / Yesterday / Date
  static String formatSmartDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return formatDate(date);
    }
  }
}
