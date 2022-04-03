import 'dart:io';
import 'package:flutter/material.dart';
import 'package:body_weight_tracker/constants/color_palette.dart';
import 'fonts.dart';

class TextStyles {
  static const TextStyle customHeading = TextStyle(
    fontFamily: Fonts.fontFamily,
    fontSize: 14,
    color: ColorPalette.primaryTextColor,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle customTextButtonStyle = TextStyle(
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.primaryColor,
    fontSize: 14,
  );

  static TextStyle customBodyText = TextStyle(
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.primaryTextColor,
    fontSize: 14,
  );
}
