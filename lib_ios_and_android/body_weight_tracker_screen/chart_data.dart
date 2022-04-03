import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/text_styles.dart';

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
          style: TextStyles.customHeading,
        ),
        SizedBox(
          height: 5,
        ),
        data,
      ],
    );
  }
}
