import 'package:body_weight_tracker/form_fields/weight_form_field.dart';
import 'package:flutter/material.dart';

///Form that allows user to add a target for their body weight tracker.
///This validates the users inputs for the target.

class SetTargetForm extends StatefulWidget {
  @override
  _SetTargetFormState createState() => _SetTargetFormState();
}

class _SetTargetFormState extends State<SetTargetForm> {
  GlobalKey<FormState> _addWeightRecordFormKey = GlobalKey<FormState>();
  double? weight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Set New Target",
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
                  WeightFormField(
                    onSaved: (value) {
                      weight = double.parse(value!);
                    },
                  )
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
              if (weight != null)
                Navigator.pop(
                  context,
                  weight,
                );
            }
          },
          child: Text("Set"),
        ),
      ],
    );
  }
}
