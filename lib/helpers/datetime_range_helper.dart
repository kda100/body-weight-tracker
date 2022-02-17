import 'package:flutter/material.dart';

/// class containing helpers to use for the DateTimeRange object.

class DateTimeRangeHelper {
  static DateTimeRange getCurrentQuarterDateRange() {
    final DateTime now = DateTime.now();
    final int currQuarter = ((now.month - 1) / 3 + 1).toInt();
    return DateTimeRange(
      start: DateTime(now.year, 3 * currQuarter - 2, 1),
      end: DateTime(now.year, 3 * currQuarter + 1, 0),
    );
  }

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
