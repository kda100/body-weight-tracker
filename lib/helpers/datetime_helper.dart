import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {
  static DateTime findStartOfWeek(DateTime dateTime) {
    return dateTime.subtract(
      Duration(days: dateTime.weekday - 1),
    );
  }

  static DateTime findEndOfWeek(DateTime dateTime) {
    return dateTime.add(
      Duration(
        days: DateTime.daysPerWeek - dateTime.weekday,
        milliseconds: 86399999,
      ),
    );
  }

  static DateTime today() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static Future<DateTime?> getDate({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: DatePickerMode.day,
      locale: Locale("en", "GB"),
    );
  }

  static DateTime? formatDDMMYYYYStringToDateTime(String? dateTime) {
    if (dateTime != null && dateTime.isNotEmpty) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      return format.parse(dateTime);
    }
    return null;
  }

  static String formatDateTimeToDDMMYYYYString(DateTime? dateTime) {
    if (dateTime != null) {
      return '${DateFormat('dd/MM/yyyy').format(dateTime)}';
    }
    return "";
  }

  static String formatDateTimeToDayMonthYearString(DateTime? dateTime) {
    if (dateTime != null) {
      return '${DateFormat('EE dd MMM yyyy').format(dateTime)}';
    }
    return "";
  }
}
