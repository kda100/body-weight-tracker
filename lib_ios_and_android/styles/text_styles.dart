import 'dart:io';
import 'package:flutter/material.dart';
import 'package:body_weight_tracker/constants/color_palette.dart';
import '../constants/fonts.dart';

class TextStyles {
  static final TextStyle customHeading = TextStyle(
    fontFamily: Fonts.fontFamily,
    fontSize: Platform.isIOS ? 17 : 14,
    color: ColorPalette.primaryTextColor,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle customTextButtonStyle = TextStyle(
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.primaryColor,
    fontSize: Platform.isIOS ? 17 : 14,
  );

  static TextStyle customBodyText = TextStyle(
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.primaryTextColor,
    fontSize: Platform.isIOS ? 17 : 14,
  );
}
