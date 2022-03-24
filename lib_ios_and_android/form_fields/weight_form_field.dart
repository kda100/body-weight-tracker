import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

///Form field for user to choose weight for a new weight record to add.

class WeightFormField extends StatelessWidget {
  final void Function(String?)? onSaved;

  WeightFormField({
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformTextFormField(
      validator: (value) {
        if (value != null) {
          if (value.isEmpty) return 'This field is required';
          if (double.tryParse(value) == null || double.parse(value) < 0)
            return "Please enter a valid weight";
          if (double.parse(value) > 1000) return "Weight is too big!";
        }
        return null;
      },
      textCapitalization: TextCapitalization.none,
      onSaved: onSaved,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.deny(
          RegExp(r"\s"),
        )
      ],
      keyboardType: TextInputType.number,
      material: (_, __) => MaterialTextFormFieldData(
        decoration: InputDecoration(
          errorMaxLines: 2,
          icon: Icon(Icons.fitness_center),
          labelText: "Weight (kg)",
          hintText: "Weight (kg)",
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
      ),
      cupertino: (_, __) => CupertinoTextFormFieldData(
        placeholder: "Weight (kg)",
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            5,
          ),
          color: Colors.grey.withOpacity(0.15),
        ),
        prefix: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(Icons.fitness_center),
        ),
      ),
    );
  }
}
