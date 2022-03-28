import 'package:body_weight_tracker/constants/color_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

///Dialog box that gives the user the ability to add weight record objects to Cloud Firestore.

class WeightDialog extends StatelessWidget {
  final Widget form;

  WeightDialog({required this.form});

  @override
  Widget build(BuildContext context) {
    final Widget widget = Padding(
      padding: const EdgeInsets.all(12.0),
      child: form,
    );
    return Center(
      child: SingleChildScrollView(
        child: PlatformWidget(
          material: (_, __) => Dialog(
            child: widget,
          ),
          cupertino: (_, __) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: widget,
          ),
        ),
      ),
    );
  }
}
