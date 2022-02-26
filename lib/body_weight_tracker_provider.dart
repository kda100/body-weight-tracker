import 'package:body_weight_tracker/firebase_services.dart';
import 'package:body_weight_tracker/helpers/datetime_helper.dart';
import 'package:body_weight_tracker/helpers/datetime_range_helper.dart';
import 'package:body_weight_tracker/models/weight_record.dart';
import 'package:body_weight_tracker/models/weight_record_with_id.dart';
import 'package:body_weight_tracker/models/weight_record_with_index.dart';
import 'package:flutter/material.dart';
import 'models/update_status.dart';

///class that controls the state of the body weight tracker screen.
///It receives user events from the screen and communicates with firebase services to make requests to firestore.
///then updates its data and notifies the screen to reflect those updates as changes to the UI.

class BodyWeightTrackerProvider with ChangeNotifier {
  final FirebaseServices _firebaseServices = FirebaseServices();
  List<WeightRecordWithId> _weightRecords =
      []; //contains the weight records that are stored on Cloud Firestore.
  List<WeightRecord> _targetWeightRecords =
      []; //stores target weight records for given date range.

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

  DateTime get day => _day;

  List<WeightRecordWithId> get weightRecordPoints => _weightRecords;

  List<WeightRecord> get targetWeightRecords => _targetWeightRecords;

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
    _firebaseServices.removeOverwriteDocs();
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

  void _resetChartData() {
    _resetChartLimits();
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
    final List<WeightRecord> targetWeightRecords = [];
    if (_target != null) {
      targetWeightRecords.add(
        WeightRecord(dateTime: dateTimeRange.start, weight: _target!),
      );
      targetWeightRecords.add(
        WeightRecord(dateTime: dateTimeRange.end, weight: _target!),
      );
      _adjustMaxAndMinWeightsWithWeight(weight: _target!);
    }
    _targetWeightRecords = targetWeightRecords;
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

  ///gets the target from firebase services target and is only called at the start of the application.
  Future<void> fetchWeightTarget() async {
    _target = await _firebaseServices.fetchTarget();
  }

  ///fetches WeightRecordsWithIds from firebase services at start of the application or when user changes date range.
  Future<void> _fetchAndSetWeightRecords() async {
    _weightRecords = await _firebaseServices.fetchWeightRecords(
        dateTimeRange: _dateTimeRange);
    _weightRecords.forEach(
      (weightRecordWithId) {
        _adjustMaxAndMinWeightsWithWeight(weight: weightRecordWithId.weight);
      },
    );
  }

  ///Before user adds a weight record to firebase
  ///a firebase services check if a WeightRecord for given date already exists.
  Future<UpdateStatus> verifyNewWeightRecord(
      {required WeightRecord weightRecord}) async {
    final UpdateStatus updateStatus = await _firebaseServices
        .queryFirestoreWithDate(dateTime: weightRecord.dateTime);
    if (updateStatus == UpdateStatus.SUCCESS) {
      addWeightRecord(weightRecord: weightRecord);
    }
    return updateStatus;
  }

  ///firebase services adds weight record to database.
  ///Then, if required, WeightRecordWithIds list is also updated so change in UI can be reflected.
  Future<UpdateStatus> addWeightRecord({
    required WeightRecord weightRecord,
  }) async {
    final DateTime dateTime = weightRecord.dateTime;
    final double weight = weightRecord.weight;
    final WeightRecordWithId? weightRecordWithId = await _firebaseServices
        .addWeightRecordToFirestore(dateTime: dateTime, weight: weight);
    if (weightRecordWithId != null) {
      if (!dateTime.isBefore(dateTimeRange.start) &&
          !dateTime.isAfter(dateTimeRange.end)) {
        //checks if weight record date is in current date range and adds to weight records list [].
        _weightRecords.add(weightRecordWithId);
        _adjustMaxAndMinWeightsWithWeight(
          weight: weight,
        );
        _weightRecords.sort(
          (a, b) => a.dateTime.millisecondsSinceEpoch
              .compareTo(b.dateTime.millisecondsSinceEpoch),
        );

        unhighlightDataPoint();
        toggleRefreshChartFlag();
        notifyListeners();
      }
      return UpdateStatus.SUCCESS;
    }
    return UpdateStatus.ERROR;
  }

  ///deletes highlighted data point using firebase services.
  ///Then change is reflected in WeightRecordWithIds list.
  Future<UpdateStatus> deleteHighlightedDataPoint() async {
    if (_highlightedRecordPoint != null) {
      final int? index = _highlightedRecordPoint?.index;
      final UpdateStatus updateStatus = await _firebaseServices
          .deleteWeightRecordFromFirestore(id: _weightRecords[index!].id);
      if (updateStatus == UpdateStatus.SUCCESS) {
        _weightRecords.removeAt(index);
        unhighlightDataPoint();
        _adjustMaxAndMinWeightsWithRecords();
        toggleRefreshChartFlag();
        notifyListeners();
      }
      return updateStatus;
    }
    return UpdateStatus.ERROR;
  }

  ///functions calls firebase services to overwrite weight record.
  ///Then is required WeightRecordWithIds list is also changed to reflect new data.
  Future<UpdateStatus> addAndDeleteWeightRecord(
      {required WeightRecord weightRecord}) async {
    final double weight = weightRecord.weight;
    final DateTime dateTime = weightRecord.dateTime;

    final WeightRecordWithId? weightRecordWithId =
        await _firebaseServices.overwriteFirestoreDoc(
      weight: weight,
      dateTime: dateTime,
    );
    if (weightRecordWithId != null) {
      if (!dateTime.isBefore(dateTimeRange.start) &&
          !dateTime.isAfter(dateTimeRange.end)) {
        //checks if weight record date is in current date range and deletes from weight records list [].
        final int index = weightRecordPoints.indexWhere((weightDataPoint) =>
            weightDataPoint.dateTime.isAtSameMomentAs(dateTime));
        _weightRecords[index] = weightRecordWithId;
        _adjustMaxAndMinWeightsWithRecords();
        toggleRefreshChartFlag();
        notifyListeners();
      }
      return UpdateStatus.SUCCESS;
    }
    return UpdateStatus.ERROR;
  }

  ///calls firebase services to set new target, then changes _target.
  Future<UpdateStatus> setNewTarget({required double target}) async {
    final UpdateStatus updateStatus =
        await _firebaseServices.setNewTargetToFirestore(target: target);
    if (updateStatus == UpdateStatus.SUCCESS) {
      _target = target;
      _setTargetWeightRecords();
      unhighlightDataPoint();
      toggleRefreshChartFlag();
      notifyListeners();
      return UpdateStatus.SUCCESS;
    }
    return updateStatus;
  }

  ///calls firebase services to delete target, then changes _target.
  Future<UpdateStatus> removeTarget() async {
    final UpdateStatus updateStatus =
        await _firebaseServices.removeTargetFromFirestore();
    if (updateStatus == UpdateStatus.SUCCESS) {
      _target = null;
      _targetWeightRecords.clear();
      _adjustMaxAndMinWeightsWithRecords();
      unhighlightDataPoint();
      toggleRefreshChartFlag();
      notifyListeners();
      return UpdateStatus.SUCCESS;
    }
    return updateStatus;
  }
}
