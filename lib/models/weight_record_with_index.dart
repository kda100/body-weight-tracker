import 'package:body_weight_tracker/models/weight_record.dart';

class WeightRecordWithIndex extends WeightRecord {
  final int index;

  WeightRecordWithIndex({
    required DateTime dateTime,
    required double weight,
    required this.index,
  }) : super(
          dateTime: dateTime,
          weight: weight,
        );
}
