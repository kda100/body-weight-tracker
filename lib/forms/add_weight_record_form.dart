import 'package:body_weight_tracker/providers/body_weight_tracker_provider.dart';
import 'package:body_weight_tracker/form_fields/date_form_field.dart';
import 'package:body_weight_tracker/form_fields/weight_form_field.dart';
import 'package:body_weight_tracker/helpers/datetime_helper.dart';
import 'package:body_weight_tracker/models/weight_record.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Form that allows user to add weight records to their body weight tracker.
///This validates the weight and date inputs before adding.

class AddWeightRecordForm extends StatefulWidget {
  @override
  _AddWeightRecordFormState createState() => _AddWeightRecordFormState();
}

class _AddWeightRecordFormState extends State<AddWeightRecordForm> {
  GlobalKey<FormState> _addWeightRecordFormKey = GlobalKey<FormState>();
  final TextEditingController _dateTextEditingController =
      TextEditingController();
  double? weight;
  DateTime? date;

  @override
  void initState() {
    _dateTextEditingController.text =
        DateTimeHelper.formatDateTimeToDDMMYYYYString(
      Provider.of<BodyWeightTrackerProvider>(context, listen: false).day,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Add Weight Record",
          style: Theme.of(context).textTheme.headline1?.copyWith(fontSize: 16),
        ),
        SizedBox(
          height: 10,
        ),
        Column(
          children: [
            Form(
              key: _addWeightRecordFormKey,
              child: Column(
                children: [
                  DateFormField(
                    onSaved: (value) {
                      date =
                          DateTimeHelper.formatDDMMYYYYStringToDateTime(value);
                    },
                    textEditingController: _dateTextEditingController,
                  ),
                  WeightFormField(onSaved: (value) {
                    weight = double.parse(value!);
                  })
                ],
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            final bool? isValid =
                _addWeightRecordFormKey.currentState?.validate();
            if (isValid ?? false) {
              _addWeightRecordFormKey.currentState?.save();
              if (date != null && weight != null)
                Navigator.pop(
                  context,
                  WeightRecord(dateTime: date!, weight: weight!),
                );
            }
          },
          child: Text("Add"),
        ),
      ],
    );
  }
}
