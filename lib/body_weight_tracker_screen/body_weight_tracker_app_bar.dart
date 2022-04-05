import 'package:body_weight_tracker/constants/strings.dart';
import 'package:body_weight_tracker/dialogs/actionable_alert_dialog.dart';
import 'package:body_weight_tracker/models/weight_record_with_index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/body_weight_tracker_provider.dart';

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

  final void Function() addWeightRecord;
  final void Function() setNewTarget;
  final void Function() removeTarget;

  BodyWeightTrackerAppBar({
    required this.addWeightRecord,
    required this.setNewTarget,
    required this.removeTarget,
  });

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
                addWeightRecord();
                break;
              case MenuItem.setNewTarget:
                setNewTarget();
                break;
              case MenuItem.removeTarget:
                removeTarget();
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
