import 'package:body_weight_tracker/body_weight_tracker_screen/body_weight_tracker_app_bar.dart';
import 'package:body_weight_tracker/constants/strings.dart';
import 'package:body_weight_tracker/dialogs/actionable_alert_dialog.dart';
import 'package:body_weight_tracker/dialogs/dismissible_alert_dialog.dart';
import 'package:body_weight_tracker/dialogs/weight_dialog.dart';
import 'package:body_weight_tracker/forms/add_weight_record_form.dart';
import 'package:body_weight_tracker/forms/set_target_form.dart';
import 'package:body_weight_tracker/models/update_status.dart';
import 'package:body_weight_tracker/models/weight_record.dart';
import 'package:body_weight_tracker/providers/body_weight_tracker_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'body_weight_tracker_screen_body.dart';

///Main screen displaying the body weight tracker to user.

class BodyWeightTrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final BodyWeightTrackerProvider bodyWeightAndStrengthTrackerProvider =
        Provider.of<BodyWeightTrackerProvider>(
      context,
      listen: false,
    );

    void addWeightRecord() async {
      final WeightRecord? weightRecord = await showDialog(
        context: context,
        builder: (context) => WeightDialog(
          form: ChangeNotifierProvider.value(
              value: bodyWeightAndStrengthTrackerProvider,
              child: AddWeightRecordForm()),
        ),
      );
      if (weightRecord != null) {
        UpdateStatus updateStatus =
            await bodyWeightAndStrengthTrackerProvider.verifyNewWeightRecord(
          weightRecord: weightRecord,
        ); //gets the UpdateStatus of the weight record the user would like to add
        if (updateStatus == UpdateStatus.OVERWRITE) {
          final bool? result = await showDialog(
            //asks user if they would like to overwrite weight record in firebase collection.
            context: context,
            builder: (context) => ActionableAlertDialog(
              title:
                  "A record for this date exists, are you sure you want to overwrite?",
            ),
          );
          if (result != null && result) {
            updateStatus = await bodyWeightAndStrengthTrackerProvider
                .addAndDeleteWeightRecord(weightRecord: weightRecord);
          } else {
            //if user does not want to overwrite data, overwrite Docs are removed.
            bodyWeightAndStrengthTrackerProvider.removeOverwriteDocs();
          }
        }
        if (updateStatus == UpdateStatus.ERROR) {
          //informs user action did not perform as intended.
          await showDialog(
            context: context,
            builder: (context) =>
                DismissibleAlertDialog(title: Strings.errorMessage),
          );
        }
      }
    }

    void setNewTarget() async {
      final double? target = await showDialog(
        context: context,
        builder: (context) => WeightDialog(
          form: SetTargetForm(),
        ),
      );
      if (target != null) {
        final UpdateStatus updateStatus =
            await bodyWeightAndStrengthTrackerProvider.setNewTarget(
                target: target);
        if (updateStatus == UpdateStatus.ERROR) {
          await showDialog(
            context: context,
            builder: (context) =>
                DismissibleAlertDialog(title: Strings.errorMessage),
          );
        }
      }
    }

    void removeTarget() async {
      final bool? result = await showDialog(
        context: context,
        builder: (context) => ActionableAlertDialog(
          title: "Are you sure you want to remove your target?",
        ),
      );
      if (result != null && result) {
        await bodyWeightAndStrengthTrackerProvider.removeTarget();
      }
    }

    return Scaffold(
      appBar: BodyWeightTrackerAppBar(
        addWeightRecord: addWeightRecord,
        setNewTarget: setNewTarget,
        removeTarget: removeTarget,
      ),
      body: BodyWeightTrackerScreenBody(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        child: FloatingActionButton(
          onPressed: addWeightRecord,
          child: Icon(
            Icons.add,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
