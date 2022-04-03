import 'package:flutter/material.dart';

/// class containing helpers to use for the DateTimeRange object.

class DateTimeRangeHelper {
  /// gets the DateTimeRange object with the max and min DateTimes of the current quarter (Q1, Q2, Q3, Q4) we are in DateTimeRange(01/01/2022, 31/03/2022)
  static DateTimeRange getCurrentQuarterDateRange() {
    final DateTime now = DateTime.now();
    final int currQuarter = ((now.month - 1) / 3 + 1).toInt();
    return DateTimeRange(
      start: DateTime(now.year, 3 * currQuarter - 2, 1),
      end: DateTime(now.year, 3 * currQuarter + 1, 0),
    );
  }

  /// adds a set number of months to the max and min DateTimes of a DateTimeRange Object.
  static DateTimeRange addMonths({
    required DateTimeRange dateTimeRange,
    required int numMonths,
  }) {
    final DateTimeRange newDateTimeRange = DateTimeRange(
      start: DateTime(
        dateTimeRange.start.year,
        dateTimeRange.start.month + numMonths,
        1,
      ),
      end: DateTime(
        dateTimeRange.end.year,
        dateTimeRange.end.month + numMonths + 1,
        0,
      ),
    );
    return newDateTimeRange;
  }

  /// subtracts a set number of months to the max and min DateTimes of a DateTimeRange Object.
  static DateTimeRange subtractMonths({
    required DateTimeRange dateTimeRange,
    required int numMonths,
  }) {
    final DateTimeRange newDateTimeRange = DateTimeRange(
      start: DateTime(
        dateTimeRange.start.year,
        dateTimeRange.start.month - numMonths,
        1,
      ),
      end: DateTime(
        dateTimeRange.end.year,
        dateTimeRange.end.month - numMonths + 1,
        0,
      ),
    );
    return newDateTimeRange;
  }
}
