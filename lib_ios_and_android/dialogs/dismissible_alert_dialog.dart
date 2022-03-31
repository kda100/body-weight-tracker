import 'package:body_weight_tracker/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///An alert dialog to display important information to user that can be dismissed straight after.

class DismissibleAlertDialog extends StatelessWidget {
  final String title;

  DismissibleAlertDialog({required this.title});

  @override
  Widget build(BuildContext context) {
    return PlatformAlertDialog(
      title: Text(
        title,
        style: TextStyles.heading1.copyWith(fontSize: 14.sp),
      ),
      actions: [
        PlatformTextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: PlatformText("Dismiss"),
        ),
      ],
    );
  }
}
