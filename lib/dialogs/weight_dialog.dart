import 'package:flutter/material.dart';

class WeightDialog extends StatelessWidget {
  final Widget form;

  WeightDialog({required this.form});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: form,
        ),
      ),
    );
  }
}
