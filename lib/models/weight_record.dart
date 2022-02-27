///Object that defines each point in the body weight tracker.
class WeightRecord {
  final DateTime _dateTime;
  final double _weight;

  WeightRecord({
    required DateTime dateTime,
    required double weight,
  })  : _dateTime = dateTime,
        _weight = weight;

  DateTime get dateTime => _dateTime;

  double get weight => _weight;
}
