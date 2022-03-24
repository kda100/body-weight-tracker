import 'package:body_weight_tracker/helpers/datetime_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../providers/body_weight_tracker_provider.dart';

///Form field for user to choose a date for a new weight record to add.

class DateFormField extends StatelessWidget {
  final void Function(String?)? onSaved;
  final TextEditingController textEditingController;

  DateFormField({
    required this.onSaved,
    required this.textEditingController,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformTextFormField(
      key: ValueKey("date"),
      controller: textEditingController,
      showCursor: false,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        final DateTime? date = await showPlatformDatePicker(
            context: context,
            initialDate: DateTimeHelper.formatDDMMYYYYStringToDateTime(
                    textEditingController.text) ??
                DateTimeHelper.today(),
            firstDate: DateTimeHelper.today().subtract(Duration(days: 365)),
            lastDate: DateTimeHelper.today().add(Duration(days: 365)),
            material: (_, __) => MaterialDatePickerData(
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  initialDatePickerMode: DatePickerMode.day,
                  locale: Locale("en", "GB"),
                ),
            cupertino: (_, __) => CupertinoDatePickerData());
        if (date != null) {
          textEditingController.text =
              DateTimeHelper.formatDateTimeToDDMMYYYYString(date);
          Provider.of<BodyWeightTrackerProvider>(context, listen: false)
              .setDay = date;
        }
      },
      onSaved: onSaved,
      readOnly: true,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'This field is required';
        }
      },
      cupertino: (_, __) => CupertinoTextFormFieldData(
        padding: EdgeInsets.all(8.0),
        placeholder: "Date",
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            5,
          ),
          color: Colors.grey.withOpacity(0.15),
        ),
        prefix: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(CupertinoIcons.calendar),
        )
      ),
      material: (_, __) => MaterialTextFormFieldData(
        decoration: InputDecoration(
          icon: Icon(
            Icons.calendar_today,
          ),
          errorMaxLines: 2,
          labelText: "Date",
        ),
      ),
      autofocus: false,
    );
  }
}
