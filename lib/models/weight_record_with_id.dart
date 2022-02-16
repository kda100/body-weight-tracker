import 'package:body_weight_tracker/models/weight_record.dart';

class WeightRecordWithId extends WeightRecord {
  final String id;

  WeightRecordWithId({
    required this.id,
    required DateTime dateTime,
    required double weight,
  }) : super(
          weight: weight,
          dateTime: dateTime,
        );
}
