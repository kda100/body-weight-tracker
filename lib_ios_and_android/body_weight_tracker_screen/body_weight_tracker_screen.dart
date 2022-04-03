import 'package:body_weight_tracker/constants/color_palette.dart';
import 'package:body_weight_tracker/constants/strings.dart';
import 'package:body_weight_tracker/styles/text_styles.dart';
import 'package:body_weight_tracker/dialogs/actionable_alert_dialog.dart';
import 'package:body_weight_tracker/dialogs/dismissible_alert_dialog.dart';
import 'package:body_weight_tracker/dialogs/weight_dialog.dart';
import 'package:body_weight_tracker/forms/add_weight_record_form.dart';
import 'package:body_weight_tracker/forms/set_target_form.dart';
import 'package:body_weight_tracker/models/update_status.dart';
import 'package:body_weight_tracker/models/weight_record.dart';
import 'package:body_weight_tracker/models/weight_record_with_index.dart';
import 'package:body_weight_tracker/providers/body_weight_tracker_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'body_weight_tracker_screen_body.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///Items contained in the app bars pop up menu
class MenuItem {
  static const String addNewRecord = "Add New Record";
  static const String setNewTarget = "Set New Target";
  static const String removeTarget = "Remove Target";
}

///Main screen displaying the body weight tracker to user.

class BodyWeightTrackerScreen extends StatefulWidget {
  @override
  State<BodyWeightTrackerScreen> createState() =>
      _BodyWeightTrackerScreenState();
}

class _BodyWeightTrackerScreenState extends State<BodyWeightTrackerScreen> {
  late BodyWeightTrackerProvider bodyWeightTrackerProvider;

  @override
  Widget build(BuildContext context) {
    final BodyWeightTrackerProvider bodyWeightTrackerProvider =
        Provider.of<BodyWeightTrackerProvider>(
      context,
      listen: false,
    );

    void addWeightRecord() async {
      final WeightRecord? weightRecord = await showDialog(
        context: context,
        barrierDismissible: Platform.isIOS ? false : true,
        builder: (context) => WeightDialog(
          form: ChangeNotifierProvider.value(
            value: bodyWeightTrackerProvider,
            child: AddWeightRecordForm(),
          ),
        ),
      );
      if (weightRecord != null) {
        UpdateStatus updateStatus =
            await bodyWeightTrackerProvider.verifyNewWeightRecord(
          weightRecord: weightRecord,
        ); //gets the UpdateStatus of the weight record the user would like to add
        if (updateStatus == UpdateStatus.OVERWRITE) {
          final bool? result = await showDialog(
            //asks user if they would like to overwrite weight record in firebase collection.
            context: context,
            barrierDismissible: Platform.isIOS ? false : true,
            builder: (context) => ActionableAlertDialog(
              title:
                  "A record for this date exists, are you sure you want to overwrite?",
            ),
          );
          if (result != null && result) {
            updateStatus = await bodyWeightTrackerProvider
                .addAndDeleteWeightRecord(weightRecord: weightRecord);
          } else {
            //if user does not want to overwrite data, overwrite Docs are removed.
            bodyWeightTrackerProvider.removeOverwriteDocs();
          }
        }
        if (updateStatus == UpdateStatus.ERROR) {
          //informs user action did not perform as intended.
          await showDialog(
            context: context,
            barrierDismissible: Platform.isIOS ? false : true,
            builder: (context) =>
                DismissibleAlertDialog(title: Strings.errorMessage),
          );
        }
      }
    }

    void setNewTarget() async {
      final double? target = await showDialog(
        context: context,
        barrierDismissible: Platform.isIOS ? false : true,
        builder: (context) => WeightDialog(
          form: SetTargetForm(),
        ),
      );
      if (target != null) {
        final UpdateStatus updateStatus =
            await bodyWeightTrackerProvider.setNewTarget(target: target);
        if (updateStatus == UpdateStatus.ERROR) {
          await showDialog(
            context: context,
            barrierDismissible: Platform.isIOS ? false : true,
            builder: (context) =>
                DismissibleAlertDialog(title: Strings.errorMessage),
          );
        }
      }
    }

    void removeTarget() async {
      final bool? result = await showDialog(
        context: context,
        barrierDismissible: Platform.isIOS ? false : true,
        builder: (context) => ActionableAlertDialog(
          title: "Are you sure you want to remove your target?",
        ),
      );
      if (result != null && result) {
        await bodyWeightTrackerProvider.removeTarget();
      }
    }

    void deleteWeightRecord(WeightRecordWithIndex weightRecord) async {
      final bool? result = await showPlatformDialog(
        context: context,
        builder: (context) => ActionableAlertDialog(
          title: "Are you sure you want to delete this point?",
        ),
      );
      if (result != null && result) {
        await bodyWeightTrackerProvider.deleteHighlightedDataPoint();
      }
    }

    CupertinoPopupMenuOptionData _getCupertinoPopupMenuOptionData(
        {required String label}) {
      return CupertinoPopupMenuOptionData(
        child: Text(
          label,
          style: TextStyles.customTextButtonStyle,
        ),
      );
    }

    return PlatformScaffold(
      appBar: PlatformAppBar(
        cupertino: (_, __) => CupertinoNavigationBarData(
          leading: PlatformIconButton(
            onPressed: addWeightRecord,
            icon: Icon(
              CupertinoIcons.add,
              color: ColorPalette.appBarIconColor,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
        title: Text(Strings.bodyWeightTrackerTitle),
        trailingActions: [
          Selector<BodyWeightTrackerProvider, WeightRecordWithIndex?>(
              selector: (context, trackerProvider) =>
                  trackerProvider.highlightedRecordPoint,
              builder: (context, highlightedDataPoint, _) {
                if (highlightedDataPoint != null)
                  return PlatformIconButton(
                    icon: Icon(
                      Platform.isIOS ? CupertinoIcons.delete : Icons.delete,
                      color: ColorPalette.appBarIconColor,
                    ),
                    onPressed: () {
                      deleteWeightRecord(highlightedDataPoint);
                    },
                    padding: EdgeInsets.zero,
                    material: (_, __) => MaterialIconButtonData(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                  );
                return SizedBox();
              }),
          PlatformPopupMenu(
            options: [
              // pop up menu items.
              PopupMenuOption(
                cupertino: (_, __) => _getCupertinoPopupMenuOptionData(
                  label: MenuItem.addNewRecord,
                ),
                label: MenuItem.addNewRecord,
                onTap: (_) {
                  addWeightRecord();
                },
              ),
              PopupMenuOption(
                cupertino: (_, __) => _getCupertinoPopupMenuOptionData(
                  label: MenuItem.setNewTarget,
                ),
                label: MenuItem.setNewTarget,
                onTap: (_) {
                  setNewTarget();
                },
              ),
              PopupMenuOption(
                cupertino: (_, __) => _getCupertinoPopupMenuOptionData(
                  label: MenuItem.removeTarget,
                ),
                label: MenuItem.removeTarget,
                onTap: (_) {
                  removeTarget();
                },
              ),
            ],
            icon: Icon(
              Platform.isIOS
                  ? CupertinoIcons.ellipsis_vertical_circle
                  : Icons.more_vert,
              color: ColorPalette.appBarIconColor,
            ),
            // icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: BodyWeightTrackerScreenBody(),
      material: (_, __) => MaterialScaffoldData(
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
      ),
    );
  }
}
