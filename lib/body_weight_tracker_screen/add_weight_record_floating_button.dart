import 'package:body_weight_tracker/constants/strings.dart';
import 'package:body_weight_tracker/dialogs/actionable_alert_dialog.dart';
import 'package:body_weight_tracker/dialogs/dismissible_alert_dialog.dart';
import 'package:body_weight_tracker/dialogs/weight_dialog.dart';
import 'package:body_weight_tracker/forms/add_weight_record_form.dart';
import 'package:body_weight_tracker/models/weight_record.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../body_weight_tracker_provider.dart';

class AddWeightRecordFloatingActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final BodyWeightTrackerProvider bodyWeightAndStrengthTrackerProvider =
        Provider.of<BodyWeightTrackerProvider>(
      context,
      listen: false,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: FloatingActionButton(
        onPressed: () async {
          final WeightRecord? weightRecord = await showDialog(
            context: context,
            builder: (context) => WeightDialog(
              form: ChangeNotifierProvider.value(
                  value: bodyWeightAndStrengthTrackerProvider,
                  child: AddWeightRecordForm()),
            ),
          );
          if (weightRecord != null) {
            BodyWeightAndStrengthTrackerUpdateStatus? updateStatus;
            updateStatus = await bodyWeightAndStrengthTrackerProvider
                .verifyNewWeightRecord(
              weightRecord: weightRecord,
            );
            if (updateStatus ==
                BodyWeightAndStrengthTrackerUpdateStatus.OVERWRITE) {
              final bool? result = await showDialog(
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
                bodyWeightAndStrengthTrackerProvider.removeOverwriteDocs();
              }
            }
            if (updateStatus ==
                BodyWeightAndStrengthTrackerUpdateStatus.ERROR) {
              await showDialog(
                context: context,
                builder: (context) =>
                    DismissibleAlertDialog(title: Strings.errorMessage),
              );
            }
          }
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
