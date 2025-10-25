import 'package:intl/intl.dart';

class DateFormatter {
  // Format ngày giờ đầy đủ: 25/10/2025 14:30
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  // Format chỉ ngày: 25/10/2025
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  // Format chỉ giờ: 14:30
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // Format ngày dạng văn bản: Thứ 2, 25 Tháng 10, 2025
  static String formatDateLong(DateTime dateTime) {
    return DateFormat('EEEE, d MMMM, yyyy', 'vi_VN').format(dateTime);
  }

  // Chuyển string sang DateTime
  static DateTime? parseDate(
    String dateString, {
    String format = 'dd/MM/yyyy',
  }) {
    try {
      return DateFormat(format).parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Tính khoảng thời gian (ví dụ: "2 giờ trước", "3 ngày trước")
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
