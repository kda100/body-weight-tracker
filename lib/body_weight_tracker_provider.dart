import 'package:body_weight_tracker/helpers/datetime_helper.dart';
import 'package:body_weight_tracker/helpers/datetime_range_helper.dart';
import 'package:body_weight_tracker/models/weight_record.dart';
import 'package:body_weight_tracker/models/weight_record_with_id.dart';
import 'package:body_weight_tracker/models/weight_record_with_index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'constants/field_names.dart';

///gives status after uploading weight record to database.

enum UpdateStatus {
  OVERWRITE,
  SUCCESS,
  ERROR,
}

///class that contains all the business logic needed for maintaining the data and state of the body weight tracker.
///It communicates with the Cloud Firestore to read and write data and controls state of the body weight tracker screen.

class BodyWeightTrackerProvider with ChangeNotifier {
  CollectionReference? _weightRecordsColRef = FirebaseFirestore.instance
      .collection(
          "Weight Records Col Ref"); //ColRef where weight records will be store.
  DocumentReference? _targetDocRef = FirebaseFirestore.instance
      .doc("Target Doc Ref"); //DocRef where target will be stored

  final List<WeightRecordWithId> _weightRecords =
      []; //contains the weight records that are stored on Cloud Firestore.
  final List<WeightRecord> _targetWeightRecords =
      []; //stores target weight records for given date range.
  final Duration _timeOutDuration = Duration(seconds: 3);

  WeightRecordWithIndex?
      _highlightedRecordPoint; //changes when users selects a data point.
  DateTimeRange _dateTimeRange = DateTimeRangeHelper
      .getCurrentQuarterDateRange(); //date range used to query weight records in firebase.
  DateTime _day = DateTimeHelper
      .today(); //to remember last date weight record was added to.

  double? _target; //stores target

  double _maxWeight =
      0; //used to control weight limits of y axis of body weight tracker chart.
  double _minWeight = double.maxFinite;

  bool _fetchedTarget =
      false; //ensures target data is only queried once from the Firebase Cloud Firestore.
  bool _refreshChartFlag =
      false; //used to control the rebuild of body weight tracker.
  bool _refreshDataFlag =
      false; //used to control the re-querying of weight records of body weight tracker.
  List<QueryDocumentSnapshot>?
      _overwriteDocs; //stores firebase docs to be overwritten.

  DateTime get day => _day;

  List<WeightRecordWithId> get weightRecordPoints => _weightRecords;

  List<WeightRecord> get targetRecordPoints => _targetWeightRecords;

  WeightRecordWithIndex? get highlightedRecordPoint => _highlightedRecordPoint;

  set setHighlightedDataPoint(WeightRecordWithIndex weightRecord) {
    _highlightedRecordPoint = weightRecord;
    notifyListeners();
  }

  unhighlightDataPoint() {
    _highlightedRecordPoint = null;
    notifyListeners();
  }

  set setDay(DateTime? day) {
    if (day != null) _day = day;
  }

  double? get target => _target;

  double get maxWeight => _maxWeight;

  double get minWeight => _minWeight;

  DateTimeRange get dateTimeRange => _dateTimeRange;

  int get weightRecordsLen => _weightRecords.length;

  int get targetWeightRecordsLen => _targetWeightRecords.length;

  bool get refreshDataFlag => _refreshDataFlag;

  bool get refreshChartFlag => _refreshChartFlag;

  removeOverwriteDocs() {
    _overwriteDocs = null;
  }

  ///triggers refresh of chart.
  void toggleRefreshChartFlag() {
    _refreshChartFlag = !_refreshChartFlag;
  }

  ///triggers re-querying of weight records data.
  void toggleRefreshDataFlag() {
    _refreshDataFlag = !_refreshDataFlag;
  }

  void _resetChartLimits() {
    _maxWeight = 0;
    _minWeight = double.maxFinite;
  }

  void _clearWeightDataPoints() {
    _weightRecords.clear();
  }

  void _clearTargetDataPoints() {
    _targetWeightRecords.clear();
  }

  void _resetChartData() {
    _resetChartLimits();
    _clearWeightDataPoints();
    _clearTargetDataPoints();
    unhighlightDataPoint();
  }

  /// adds 3 months to date range used to query firebase database.
  void addQuarter() {
    if (!_dateTimeRange.end.isAfter(
      DateTimeHelper.today().add(
        Duration(days: 365),
      ),
    )) {
      _resetChartData();
      _dateTimeRange = DateTimeRangeHelper.addMonths(
        dateTimeRange: _dateTimeRange,
        numMonths: 3,
      );
      toggleRefreshDataFlag();
      notifyListeners();
    }
  }

  /// subtracts 3 months to date range used to query firebase database.
  void subtractQuarter() {
    if (!_dateTimeRange.start.isBefore(
      DateTimeHelper.today().subtract(
        Duration(days: 365),
      ),
    )) {
      _resetChartData();
      _dateTimeRange = DateTimeRangeHelper.subtractMonths(
        dateTimeRange: _dateTimeRange,
        numMonths: 3,
      );
      toggleRefreshDataFlag();
      notifyListeners();
    }
  }

  ///changes max and min weights when a new weight record has been added or read from firebase.
  void _adjustMaxAndMinWeightsWithWeight({required double weight}) {
    if (weight > _maxWeight) _maxWeight = weight;
    if (weight < _minWeight) _minWeight = weight;
  }

  ///adjusts max and min weights when a weight record has been deleted from list or target has been removed.
  void _adjustMaxAndMinWeightsWithRecords() {
    _resetChartLimits();
    _weightRecords.forEach((weightRecord) {
      _adjustMaxAndMinWeightsWithWeight(weight: weightRecord.weight);
    });
    if (_target != null) _adjustMaxAndMinWeightsWithWeight(weight: _target!);
  }

  ///sets weight records used for target data when a new target has been established
  ///or when date range for body weight tracker has changed.
  ///This is so target can reflected as a straight line in the body weight tracker chart.
  void _setTargetWeightRecords() async {
    if (_target != null) {
      _targetWeightRecords.add(
        WeightRecord(dateTime: dateTimeRange.start, weight: _target!),
      );
      _targetWeightRecords.add(
        WeightRecord(dateTime: dateTimeRange.end, weight: _target!),
      );
      _adjustMaxAndMinWeightsWithWeight(weight: _target!);
    }
  }

  ///called when body weight tracker needs to fetch weight record data when date range changes
  ///or at the start of the application.
  Future<void> fetchData() async {
    if (!_fetchedTarget) {
      await fetchWeightTarget();
      notifyListeners();
      _fetchedTarget = true;
    }
    await _fetchAndSetWeightRecords();
    _setTargetWeightRecords();
  }

  ///fetches and sets target and is only called at the start of the application.
  Future<void> fetchWeightTarget() async {
    final DocumentSnapshot? docSnapshot = (await _targetDocRef?.get());
    if (docSnapshot != null) {
      if (docSnapshot.exists) {
        if (docSnapshot.data()?.isNotEmpty ?? false) {
          final double target = docSnapshot[FieldNames.targetField].toDouble();
          _target = target;
        }
      }
    }
  }

  ///fetches and sets weight records with their ids at start of the application or when user changes date range.
  Future<void> _fetchAndSetWeightRecords() async {
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
            _weightRecords.add(
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

  ///Before user adds a weight record to firebase
  ///a check is done to determine if a weight record already exists for the date given.
  Future<UpdateStatus> verifyNewWeightRecord(
      {required WeightRecord weightRecord}) async {
    List<QueryDocumentSnapshot>? queryDocSnapshot;
    try {
      queryDocSnapshot = (await _weightRecordsColRef
              ?.where(FieldNames.dateField, isEqualTo: weightRecord.dateTime)
              .get()
              .timeout(_timeOutDuration))
          ?.docs;
    } catch (e) {
      return UpdateStatus.ERROR;
    }
    if (queryDocSnapshot != null && queryDocSnapshot.length > 0) {
      _overwriteDocs =
          queryDocSnapshot; // saves a reference to docs to be overwritten.
      return UpdateStatus.OVERWRITE;
    }
    addWeightRecord(weightRecord: weightRecord);
    return UpdateStatus.SUCCESS;
  }

  ///performed when user chooses to add a new weight record to their body weight tracker.
  Future<UpdateStatus> addWeightRecord({
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
      return UpdateStatus.ERROR;
    }
    if (!dateTime.isBefore(dateTimeRange.start) &&
        !dateTime.isAfter(dateTimeRange.end)) {
      //checks if weight record date is in current date range and adds to weight records list [].
      if (docRef != null) {
        _weightRecords.add(
          WeightRecordWithId(
            dateTime: dateTime,
            weight: weight,
            id: docRef.id,
          ),
        );
        _adjustMaxAndMinWeightsWithWeight(
          weight: weight,
        );
        _weightRecords.sort(
          (a, b) => a.dateTime.millisecondsSinceEpoch
              .compareTo(b.dateTime.millisecondsSinceEpoch),
        );
      }
      unhighlightDataPoint();
      toggleRefreshChartFlag();
      notifyListeners();
    }
    return UpdateStatus.SUCCESS;
  }

  ///deletes highlighted data point from firebase database and weight records list.
  Future<UpdateStatus> deleteHighlightedDataPoint() async {
    if (_highlightedRecordPoint != null) {
      final int? index = _highlightedRecordPoint?.index;
      final WeightRecordWithId weightRecordWithId = _weightRecords[index!];
      try {
        await _weightRecordsColRef
            ?.doc(weightRecordWithId.id)
            .delete()
            .timeout(_timeOutDuration);
      } catch (e) {
        return UpdateStatus.ERROR;
      }
      _weightRecords.removeAt(index);
      unhighlightDataPoint();
      _adjustMaxAndMinWeightsWithRecords();
      toggleRefreshChartFlag();
      notifyListeners();
      return UpdateStatus.SUCCESS;
    }
    return UpdateStatus.ERROR;
  }

  ///called when user would like to overwrite a weight record for a date already contained
  ///in the collection reference that stores their weight records.
  Future<UpdateStatus> addAndDeleteWeightRecord(
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
      return UpdateStatus.ERROR;
    }
    removeOverwriteDocs();
    if (docRef != null) {
      if (!dateTime.isBefore(dateTimeRange.start) &&
          !dateTime.isAfter(dateTimeRange.end)) {
        //checks if weight record date is in current date range and deletes from weight records list [].
        final int index = weightRecordPoints.indexWhere((weightDataPoint) =>
            weightDataPoint.dateTime.isAtSameMomentAs(dateTime));
        _weightRecords[index] = WeightRecordWithId(
            id: docRef.id, dateTime: dateTime, weight: weight);
        _adjustMaxAndMinWeightsWithRecords();
        toggleRefreshChartFlag();
        notifyListeners();
      }
      return UpdateStatus.SUCCESS;
    }
    return UpdateStatus.ERROR;
  }

  ///sets new target to firebase database.
  Future<UpdateStatus> setNewTarget({required double target}) async {
    try {
      await _targetDocRef?.set({
        FieldNames.targetField: target,
      }).timeout(_timeOutDuration);
    } catch (e) {
      return UpdateStatus.ERROR;
    }
    _target = target;
    _clearTargetDataPoints();
    _setTargetWeightRecords();
    unhighlightDataPoint();
    toggleRefreshChartFlag();
    notifyListeners();
    return UpdateStatus.SUCCESS;
  }

  ///removes target from firebase database.
  Future<UpdateStatus> removeTarget() async {
    try {
      await _targetDocRef?.set({}).timeout(_timeOutDuration);
    } catch (e) {
      return UpdateStatus.ERROR;
    }
    _target = null;
    _clearTargetDataPoints();
    _adjustMaxAndMinWeightsWithRecords();
    unhighlightDataPoint();
    toggleRefreshChartFlag();
    notifyListeners();
    return UpdateStatus.SUCCESS;
  }
}
