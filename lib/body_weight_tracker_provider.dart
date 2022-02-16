import 'package:body_weight_tracker/helpers/datetime_helper.dart';
import 'package:body_weight_tracker/helpers/datetime_range_helper.dart';
import 'package:body_weight_tracker/models/weight_record.dart';
import 'package:body_weight_tracker/models/weight_record_with_id.dart';
import 'package:body_weight_tracker/models/weight_record_with_index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'constants/field_names.dart';

enum BodyWeightTrackerUpdateStatus {
  OVERWRITE,
  SUCCESS,
  ERROR,
}

class BodyWeightTrackerProvider with ChangeNotifier {
  DocumentReference? _docRef;
  CollectionReference? _weightRecordsColRef =
      FirebaseFirestore.instance.collection("Your Collection Path");
  final String _weightRecordsDisplayName = "Weight";
  final String _targetDisplayName = "Target";
  final List<WeightRecordWithId> _weightRecordsPoints = [];
  final List<WeightRecord> _targetRecordPoints = [];
  final Duration _timeOutDuration = Duration(seconds: 3);

  WeightRecordWithIndex? _highlightedRecordPoint;
  DateTimeRange _dateTimeRange =
      DateTimeRangeHelper.getCurrentQuarterDateRange();
  DateTime _day = DateTimeHelper.today();
  double? _target;
  double _maxWeight = 0;
  double _minWeight = double.maxFinite;
  bool _fetchedTarget = false;
  bool _refreshChartFlag = false;
  bool _refreshDataFlag = false;
  List<QueryDocumentSnapshot>? _overwriteDocs;

  String get weightRecordsDisplayName => _weightRecordsDisplayName;

  String get targetDisplayName => _targetDisplayName;

  DateTime get day => _day;

  List<WeightRecordWithId> get weightRecordPoints => _weightRecordsPoints;

  List<WeightRecord> get targetRecordPoints => _targetRecordPoints;

  WeightRecordWithIndex? get highlightedRecordPoint => _highlightedRecordPoint;

  set setHighlightedDataPoint(WeightRecordWithIndex weightRecord) {
    _highlightedRecordPoint = weightRecord;
    notifyListeners();
  }

  set setDay(DateTime? day) {
    if (day != null) _day = day;
  }

  unhighlightDataPoint() {
    _highlightedRecordPoint = null;
    notifyListeners();
  }

  double? get target => _target;

  double get maxWeight => _maxWeight;

  double get minWeight => _minWeight;

  DateTimeRange get dateTimeRange => _dateTimeRange;

  int get weightPointsLen => _weightRecordsPoints.length;

  int get targetPointsLen => _targetRecordPoints.length;

  bool get refreshDataFlag => _refreshDataFlag;

  bool get refreshChartFlag => _refreshChartFlag;

  removeOverwriteDocs() {
    _overwriteDocs = null;
  }

  void nextWeightRecordPoint() {}

  void prevWeightRecordPoint() {}

  void addQuarter() {
    if (!_dateTimeRange.end.isAfter(
      DateTimeHelper.today().add(
        Duration(days: 365),
      ),
    )) {
      resetChartData();
      _dateTimeRange = DateTimeRangeHelper.addMonths(
        dateTimeRange: _dateTimeRange,
        numMonths: 3,
      );
      toggleRefreshDataFlag();
      notifyListeners();
    }
  }

  void subtractQuarter() {
    if (!_dateTimeRange.start.isBefore(
      DateTimeHelper.today().subtract(
        Duration(days: 365),
      ),
    )) {
      resetChartData();
      _dateTimeRange = DateTimeRangeHelper.subtractMonths(
        dateTimeRange: _dateTimeRange,
        numMonths: 3,
      );
      toggleRefreshDataFlag();
      notifyListeners();
    }
  }

  void toggleRefreshChartFlag() {
    _refreshChartFlag = !_refreshChartFlag;
  }

  void toggleRefreshDataFlag() {
    _refreshDataFlag = !_refreshDataFlag;
  }

  void _resetChartLimits() {
    _maxWeight = 0;
    _minWeight = double.maxFinite;
  }

  void _clearWeightDataPoints() {
    _weightRecordsPoints.clear();
  }

  void _clearTargetDataPoints() {
    _targetRecordPoints.clear();
  }

  void resetChartData() {
    _resetChartLimits();
    _clearWeightDataPoints();
    _clearTargetDataPoints();
    unhighlightDataPoint();
  }

  void resetAllData() {
    resetChartData();
    _target = null;
    _fetchedTarget = false;
  }

  Future<void> fetchData() async {
    if (!_fetchedTarget) {
      await fetchWeightTarget();
      notifyListeners();
      _fetchedTarget = true;
    }
    await _fetchAndSetTimeSeriesWeightChartData();
    _setTimeSeriesWeightTargetChartData();
  }

  Future<void> fetchWeightTarget() async {
    final DocumentSnapshot? docSnapshot = (await _docRef?.get());
    if (docSnapshot != null) {
      if (docSnapshot.exists) {
        if (docSnapshot.data()?.isNotEmpty ?? false) {
          final double target = docSnapshot[FieldNames.targetField].toDouble();
          _target = target;
        }
      }
    }
  }

  void _adjustMaxAndMinWeightsWithWeight({required double weight}) {
    if (weight > _maxWeight) _maxWeight = weight;
    if (weight < _minWeight) _minWeight = weight;
  }

  void _adjustMaxAndMinWeightsWithRecords() {
    _resetChartLimits();
    _weightRecordsPoints.forEach((weightRecord) {
      _adjustMaxAndMinWeightsWithWeight(weight: weightRecord.weight);
    });
    if (_target != null) _adjustMaxAndMinWeightsWithWeight(weight: _target!);
  }

  void _setTimeSeriesWeightTargetChartData() async {
    if (_target != null) {
      _targetRecordPoints.add(
        WeightRecord(dateTime: dateTimeRange.start, weight: _target!),
      );
      _targetRecordPoints.add(
        WeightRecord(dateTime: dateTimeRange.end, weight: _target!),
      );
      _adjustMaxAndMinWeightsWithWeight(weight: _target!);
    }
  }

  Future<void> _fetchAndSetTimeSeriesWeightChartData() async {
    final List<QueryDocumentSnapshot>? queryDocSnapshot =
        (await _weightRecordsColRef
                ?.where(
                  FieldNames.dateField,
                  isGreaterThanOrEqualTo: _dateTimeRange.start,
                  isLessThanOrEqualTo: _dateTimeRange.end,
                )
                .get())
            ?.docs;
    queryDocSnapshot?.forEach(
      (docSnapshot) {
        if (docSnapshot.exists) {
          final Map<String, dynamic>? docData = docSnapshot.data();
          if (docData != null) {
            final double weight = docData[FieldNames.weightField].toDouble();
            _adjustMaxAndMinWeightsWithWeight(weight: weight);
            _weightRecordsPoints.add(
              WeightRecordWithId(
                id: docSnapshot.id,
                dateTime: docData[FieldNames.dateField].toDate(),
                weight: docData[FieldNames.weightField].toDouble(),
              ),
            );
          }
        }
      },
    );
  }

  Future<BodyWeightTrackerUpdateStatus> verifyNewWeightRecord(
      {required WeightRecord weightRecord}) async {
    List<QueryDocumentSnapshot>? queryDocSnapshot;
    try {
      queryDocSnapshot = (await _weightRecordsColRef
              ?.where(FieldNames.dateField, isEqualTo: weightRecord.dateTime)
              .get()
              .timeout(_timeOutDuration))
          ?.docs;
    } catch (e) {
      return BodyWeightTrackerUpdateStatus.ERROR;
    }
    if (queryDocSnapshot != null && queryDocSnapshot.length > 0) {
      _overwriteDocs = queryDocSnapshot;
      return BodyWeightTrackerUpdateStatus.OVERWRITE;
    }
    addWeightRecord(weightRecord: weightRecord);
    return BodyWeightTrackerUpdateStatus.SUCCESS;
  }

  Future<BodyWeightTrackerUpdateStatus> addAndDeleteWeightRecord(
      {required WeightRecord weightRecord}) async {
    final double weight = weightRecord.weight;
    final DateTime dateTime = weightRecord.dateTime;
    DocumentReference? docRef;
    try {
      final int overwriteDocsLen = _overwriteDocs?.length ?? 0;
      for (int i = 0; i < overwriteDocsLen; i++) {
        final QueryDocumentSnapshot? queryDocumentSnapshot = _overwriteDocs?[i];
        if (i == overwriteDocsLen - 1) {
          docRef = _weightRecordsColRef?.doc(queryDocumentSnapshot?.id);
          await docRef?.update({
            FieldNames.weightField: weight,
          }).timeout(_timeOutDuration);
        } else
          await _weightRecordsColRef
              ?.doc(queryDocumentSnapshot?.id)
              .delete()
              .timeout(_timeOutDuration);
      }
    } catch (e) {
      return BodyWeightTrackerUpdateStatus.ERROR;
    }
    removeOverwriteDocs();
    if (docRef != null) {
      if (!dateTime.isBefore(dateTimeRange.start) &&
          !dateTime.isAfter(dateTimeRange.end)) {
        final int index = weightRecordPoints.indexWhere(
          (weightDataPoint) =>
              weightDataPoint.dateTime.millisecondsSinceEpoch ==
              dateTime.millisecondsSinceEpoch,
        );
        _weightRecordsPoints[index] = WeightRecordWithId(
            id: docRef.id, dateTime: dateTime, weight: weight);
        _adjustMaxAndMinWeightsWithRecords();
        toggleRefreshChartFlag();
        notifyListeners();
      }
      return BodyWeightTrackerUpdateStatus.SUCCESS;
    }
    return BodyWeightTrackerUpdateStatus.ERROR;
  }

  Future<BodyWeightTrackerUpdateStatus> addWeightRecord({
    required WeightRecord weightRecord,
  }) async {
    final DateTime dateTime = weightRecord.dateTime;
    final double weight = weightRecord.weight;
    final DocumentReference? docRef = _weightRecordsColRef?.doc();
    try {
      docRef?.set(
        {
          FieldNames.dateField: Timestamp.fromDate(dateTime),
          FieldNames.weightField: weight,
        },
      ).timeout(_timeOutDuration);
    } catch (e) {
      return BodyWeightTrackerUpdateStatus.ERROR;
    }
    if (!dateTime.isBefore(dateTimeRange.start) &&
        !dateTime.isAfter(dateTimeRange.end)) {
      if (docRef != null) {
        _weightRecordsPoints.add(
          WeightRecordWithId(
            dateTime: dateTime,
            weight: weight,
            id: docRef.id,
          ),
        );
        _adjustMaxAndMinWeightsWithWeight(
          weight: weight,
        );
        _weightRecordsPoints.sort(
          (a, b) => a.dateTime.millisecondsSinceEpoch
              .compareTo(b.dateTime.millisecondsSinceEpoch),
        );
      }
      unhighlightDataPoint();
      toggleRefreshChartFlag();
      notifyListeners();
    }
    return BodyWeightTrackerUpdateStatus.SUCCESS;
  }

  Future<BodyWeightTrackerUpdateStatus>
      deleteHighlightedDataPoint() async {
    if (_highlightedRecordPoint != null) {
      final int? index = _highlightedRecordPoint?.index;
      final WeightRecordWithId weightRecordWithId =
          _weightRecordsPoints[index!];
      try {
        await _weightRecordsColRef
            ?.doc(weightRecordWithId.id)
            .delete()
            .timeout(_timeOutDuration);
      } catch (e) {
        return BodyWeightTrackerUpdateStatus.ERROR;
      }
      _weightRecordsPoints.removeAt(index);
      unhighlightDataPoint();
      _adjustMaxAndMinWeightsWithRecords();
      toggleRefreshChartFlag();
      notifyListeners();
      return BodyWeightTrackerUpdateStatus.SUCCESS;
    }
    return BodyWeightTrackerUpdateStatus.ERROR;
  }

  Future<BodyWeightTrackerUpdateStatus> setNewTarget(
      {required double target}) async {
    try {
      await _docRef?.set({
        FieldNames.targetField: target,
      }).timeout(_timeOutDuration);
    } catch (e) {
      return BodyWeightTrackerUpdateStatus.ERROR;
    }
    _target = target;
    _clearTargetDataPoints();
    _setTimeSeriesWeightTargetChartData();
    unhighlightDataPoint();
    toggleRefreshChartFlag();
    notifyListeners();
    return BodyWeightTrackerUpdateStatus.SUCCESS;
  }

  Future<BodyWeightTrackerUpdateStatus> removeTarget() async {
    try {
      await _docRef?.set({}).timeout(_timeOutDuration);
    } catch (e) {
      return BodyWeightTrackerUpdateStatus.ERROR;
    }
    _target = null;
    _clearTargetDataPoints();
    _adjustMaxAndMinWeightsWithRecords();
    unhighlightDataPoint();
    toggleRefreshChartFlag();
    notifyListeners();
    return BodyWeightTrackerUpdateStatus.SUCCESS;
  }
}
