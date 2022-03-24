import 'package:flutter/material.dart';

///widget used to display different information presented in the body weight tracker chart
///The selected date, selected weight and target.

class ChartData extends StatelessWidget {
  final String header;
  final Widget data;

  ChartData({
    required this.header,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          header,
          style: Theme.of(context).textTheme.headline1,
        ),
        SizedBox(
          height: 5,
        ),
        data
      ],
    );
  }
}
