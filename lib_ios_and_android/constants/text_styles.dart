import 'package:flutter/material.dart';
import 'package:body_weight_tracker/constants/color_palette.dart';

import 'fonts.dart';

class TextStyles {
  static const TextStyle dateScrollableDateBarTextStyle = TextStyle(
    fontFamily: Fonts.fontFamily,
    fontSize: 14,
    color: ColorPalette.primaryTextColor,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle primaryHeaderTextStyle = TextStyle(
    fontFamily: Fonts.fontFamily,
    fontSize: 14,
    color: ColorPalette.primaryTextColor,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle secondaryHeaderTextStyle = TextStyle(
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.secondaryTextColor,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  static const TextStyle popupMenuLabelTextStyle = TextStyle(
    fontFamily: Fonts.fontFamily,
    fontSize: 18,
    color: ColorPalette.primaryColor,
  );

  static const TextStyle alertDialogTextStyle = TextStyle(
    fontSize: 14,
    color: ColorPalette.primaryTextColor,
    fontFamily: Fonts.fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle primaryTextStyle = TextStyle(
    fontFamily: Fonts.fontFamily,
    fontSize: 14,
    color: ColorPalette.primaryTextColor,
  );

  static const TextStyle secondaryTextStyle = TextStyle(
    fontFamily: Fonts.fontFamily,
    fontSize: 14,
    color: ColorPalette.primaryColor,
  );
}
