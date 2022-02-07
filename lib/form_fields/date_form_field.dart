import 'package:body_weight_tracker/helpers/datetime_helper.dart';
import 'package:flutter/material.dart';

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
        final DateTime? date = await DateTimeHelper.getDate(
          context: context,
          initialDate: DateTimeHelper.formatDDMMYYYYStringToDateTime(
                  textEditingController.text) ??
              DateTimeHelper.today(),
          firstDate: DateTimeHelper.today().subtract(Duration(days: 365)),
          lastDate: DateTimeHelper.today().add(Duration(days: 365)),
        );
        if (date != null) {
          textEditingController.text =
              DateTimeHelper.formatDateTimeToDDMMYYYYString(date);
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
