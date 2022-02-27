import 'package:body_weight_tracker/models/weight_record.dart';

class WeightRecordWithId extends WeightRecord {
  final String _id; //store id reference for item in firebase.

  WeightRecordWithId({
    required String id,
    required DateTime dateTime,
    required double weight,
  })  : _id = id,
        super(
          weight: weight,
          dateTime: dateTime,
        );

  String get id => _id;
}
