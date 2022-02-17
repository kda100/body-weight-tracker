import 'package:body_weight_tracker/body_weight_tracker_screen/body_weight_tracker_app_bar.dart';
import 'package:flutter/material.dart';
import 'add_weight_record_floating_button.dart';
import 'body_weight_tracker_screen_body.dart';

///Main screen displaying the body weight tracker to user.

class BodyWeightTrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BodyWeightTrackerAppBar(),
      body: BodyWeightTrackerScreenBody(),
      floatingActionButton: AddWeightRecordFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
