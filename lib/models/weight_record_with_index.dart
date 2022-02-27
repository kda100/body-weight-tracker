import 'package:body_weight_tracker/models/weight_record.dart';

class WeightRecordWithIndex extends WeightRecord {
  final int _index; //stores index position of weight record in list.

  WeightRecordWithIndex({
    required DateTime dateTime,
    required double weight,
    required int index,
  })  : _index = index,
        super(
          dateTime: dateTime,
          weight: weight,
        );

  int get index => _index;
}
