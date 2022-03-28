import 'package:body_weight_tracker/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

///An Alert dialog with two actions for a yes and no response.

class ActionableAlertDialog extends StatelessWidget {
  final String title;

  ActionableAlertDialog({
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    return PlatformAlertDialog(
      content: Text(
        title,
        style: TextStyles.alertDialogTextStyle,
      ),
      actions: [
        PlatformTextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: PlatformText(
            "Yes",
          ),
        ),
        PlatformTextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: PlatformText(
            "No",
          ),
        ),
      ],
    );
  }
}
