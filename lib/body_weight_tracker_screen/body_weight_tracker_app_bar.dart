import 'package:body_weight_tracker/constants/strings.dart';
import 'package:body_weight_tracker/dialogs/actionable_alert_dialog.dart';
import 'package:body_weight_tracker/dialogs/dismissible_alert_dialog.dart';
import 'package:body_weight_tracker/dialogs/weight_dialog.dart';
import 'package:body_weight_tracker/forms/add_weight_record_form.dart';
import 'package:body_weight_tracker/forms/set_target_form.dart';
import 'package:body_weight_tracker/models/update_status.dart';
import 'package:body_weight_tracker/models/weight_record.dart';
import 'package:body_weight_tracker/models/weight_record_with_index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../body_weight_tracker_provider.dart';

///Items contained in the app bars pop up menu
class MenuItem {
  static const String addNewRecord = "Add New Record";
  static const String setNewTarget = "Set New Target";
  static const String removeTarget = "Remove Target";
}

///App bar of BodyWeightTracker screen.
class BodyWeightTrackerAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final List<String> menuItems = [
    // pop up menu items.
    MenuItem.addNewRecord,
    MenuItem.setNewTarget,
    MenuItem.removeTarget,
  ];

  @override
  Widget build(BuildContext context) {
    final BodyWeightTrackerProvider bodyWeightAndStrengthTrackerProvider =
        Provider.of<BodyWeightTrackerProvider>(
      context,
      listen: false,
    );
    return AppBar(
      title: Text(Strings.bodyWeightTrackerTitle),
      actions: [
        // When data point is highlighted then delete icon is shown.
        Selector<BodyWeightTrackerProvider, WeightRecordWithIndex?>(
            selector: (context, trackerProvider) =>
                trackerProvider.highlightedRecordPoint,
            builder: (context, highlightedDataPoint, _) {
              if (highlightedDataPoint != null)
                return IconButton(
                  icon: Icon(Icons.delete),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () async {
                    final bool? result = await showDialog(
                      context: context,
                      builder: (context) => ActionableAlertDialog(
                        title: "Are you sure you want to delete this point?",
                      ),
                    );
                    if (result != null && result) {
                      await bodyWeightAndStrengthTrackerProvider
                          .deleteHighlightedDataPoint();
                    }
                  },
                );
              return SizedBox();
            }),
        //Popup Menu where users can add weight records, set a target and remove the target.
        PopupMenuButton<String>(
          itemBuilder: (context) {
            return menuItems
                .map((String item) => PopupMenuItem<String>(
                      child: Text(item),
                      value: item,
                    ))
                .toList();
          },
          onSelected: (item) async {
            switch (item) {
              case MenuItem.addNewRecord:
                final WeightRecord? weightRecord = await showDialog(
                  context: context,
                  builder: (context) => WeightDialog(
                    form: ChangeNotifierProvider.value(
                      value: bodyWeightAndStrengthTrackerProvider,
                      child: AddWeightRecordForm(),
                    ),
                  ),
                );
                if (weightRecord != null) {
                  UpdateStatus? updateStatus;
                  updateStatus = await bodyWeightAndStrengthTrackerProvider
                      .verifyNewWeightRecord(
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
                      bodyWeightAndStrengthTrackerProvider
                          .removeOverwriteDocs();
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
                break;
              case MenuItem.setNewTarget:
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
                break;
              case MenuItem.removeTarget:
                final bool? result = await showDialog(
                  context: context,
                  builder: (context) => ActionableAlertDialog(
                    title: "Are you sure you want to remove your target?",
                  ),
                );
                if (result != null && result) {
                  await bodyWeightAndStrengthTrackerProvider.removeTarget();
                }
                break;
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
