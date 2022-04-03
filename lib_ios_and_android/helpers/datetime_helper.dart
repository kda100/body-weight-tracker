import 'package:intl/intl.dart';

/// class containing helpers to use for the DateTime object.

class DateTimeHelper {
  ///gets current day.
  static DateTime today() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// changes "17/02/2022" format -> DateTime Object.
  static DateTime? formatDDMMYYYYStringToDateTime(String? dateTime) {
    if (dateTime != null && dateTime.isNotEmpty) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      return format.parse(dateTime);
    }
    return null;
  }

  /// changes DateTime Object to "17/02/2022" format.
  static String formatDateTimeToDDMMYYYYString(DateTime? dateTime) {
    if (dateTime != null) {
      return '${DateFormat('dd/MM/yyyy').format(dateTime)}';
    }
    return "";
  }

  /// changes DateTime to "Thu 17 Feb 2022" format.
  static String formatDateTimeToDayMonthYearString(DateTime? dateTime) {
    if (dateTime != null) {
      return '${DateFormat('EE dd MMM yyyy').format(dateTime)}';
    }
    return "";
  }
}
