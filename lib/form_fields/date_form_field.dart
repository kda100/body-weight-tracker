import 'package:body_weight_tracker/helpers/datetime_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../body_weight_tracker_provider.dart';

///Form field for user to choose date object for the weight record object.

class DateFormField extends StatelessWidget {
  final void Function(String?)? onSaved;
  final TextEditingController textEditingController;

  DateFormField({
    required this.onSaved,
    required this.textEditingController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey("date"),
      controller: textEditingController,
      showCursor: false,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        final DateTime? date = await showDatePicker(
          context: context,
          initialDate: DateTimeHelper.formatDDMMYYYYStringToDateTime(
                  textEditingController.text) ??
              DateTimeHelper.today(),
          firstDate: DateTimeHelper.today().subtract(Duration(days: 365)),
          lastDate: DateTimeHelper.today().add(Duration(days: 365)),
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDatePickerMode: DatePickerMode.day,
          locale: Locale("en", "GB"),
        );
        if (date != null) {
          textEditingController.text =
              DateTimeHelper.formatDateTimeToDDMMYYYYString(date);
          Provider.of<BodyWeightTrackerProvider>(context, listen: false)
              .setDay = date;
        }
      },
      onSaved: onSaved,
      readOnly: true,
      decoration: InputDecoration(
        icon: Icon(
          Icons.calendar_today,
        ),
        errorMaxLines: 2,
        labelText: "Date",
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'This field is required';
        }
      },
      autofocus: false,
    );
  }
}
