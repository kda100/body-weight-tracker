import 'package:flutter/material.dart';
import 'package:body_weight_tracker/constants/color_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'fonts.dart';

class TextStyles {
  static const TextStyle heading1 = TextStyle(
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.primaryTextColor,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.secondaryTextColor,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle textButtonStyle = TextStyle(
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.primaryColor,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontFamily: Fonts.fontFamily,
    color: ColorPalette.primaryTextColor,
  );
}
