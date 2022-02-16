import 'package:body_weight_tracker/constants/strings.dart';
import 'package:body_weight_tracker/dialogs/actionable_alert_dialog.dart';
import 'package:body_weight_tracker/dialogs/dismissible_alert_dialog.dart';
import 'package:body_weight_tracker/dialogs/weight_dialog.dart';
import 'package:body_weight_tracker/forms/add_weight_record_form.dart';
import 'package:body_weight_tracker/forms/set_target_form.dart';
import 'package:body_weight_tracker/models/weight_record.dart';
import 'package:body_weight_tracker/models/weight_record_with_index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../body_weight_tracker_provider.dart';

class MenuItem {
  static const String addNewRecord = "Add New Record";
  static const String setNewTarget = "Set New Target";
  static const String removeTarget = "Remove Target";
}

class BodyWeightTrackerAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final List<String> menuItems = [
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
                    if (result != null) {
                      if (result) {
                        await bodyWeightAndStrengthTrackerProvider
                            .deleteHighlightedDataPoint();
                      }
                    }
                  },
                );
              return SizedBox();
            }),
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
                    form: WeightDialog(
                      form: ChangeNotifierProvider.value(
                        value: bodyWeightAndStrengthTrackerProvider,
                        child: AddWeightRecordForm(),
                      ),
                    ),
                  ),
                );
                if (weightRecord != null) {
                  BodyWeightTrackerUpdateStatus? updateStatus;
                  updateStatus = await bodyWeightAndStrengthTrackerProvider
                      .verifyNewWeightRecord(
                    weightRecord: weightRecord,
                  );
                  if (updateStatus == BodyWeightTrackerUpdateStatus.OVERWRITE) {
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
                      bodyWeightAndStrengthTrackerProvider
                          .removeOverwriteDocs();
                    }
                  }
                  if (updateStatus == BodyWeightTrackerUpdateStatus.ERROR) {
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
                  final BodyWeightTrackerUpdateStatus updateStatus =
                      await bodyWeightAndStrengthTrackerProvider.setNewTarget(
                          target: target);
                  if (updateStatus == BodyWeightTrackerUpdateStatus.ERROR) {
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
