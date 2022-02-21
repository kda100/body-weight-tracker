///Object that defines each point in the body weight tracker.
class WeightRecord {
  final DateTime dateTime;
  final double weight;

  WeightRecord({
    required this.dateTime,
    required this.weight,
  });
}
