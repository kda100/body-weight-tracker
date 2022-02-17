import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// class containing helpers to use for the DateTime object.

class DateTimeHelper {
  static DateTime today() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
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
