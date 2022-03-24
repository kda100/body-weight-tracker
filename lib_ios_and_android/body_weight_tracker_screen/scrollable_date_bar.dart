import 'dart:io';

import 'package:body_weight_tracker/constants/color_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

///This is so user can control the date range of the weight record points that is reflected
///in the body weight tracker.

class ScrollableDateBar extends StatelessWidget {
  final Widget dateWidget;
  final void Function() onIncrease;
  final void Function() onDecrease;

  ScrollableDateBar(
      {required this.dateWidget,
      required this.onDecrease,
      required this.onIncrease});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.2),
        ),
      ),
      height: 40,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          dateWidget,
          SizedBox(
            child: Row(
              children: [
                PlatformIconButton(
                  material: (_, __) => MaterialIconButtonData(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  cupertino: (_, __) =>
                      CupertinoIconButtonData(padding: EdgeInsets.zero),
                  onPressed: onDecrease,
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    color: ColorPalette.primaryIconColor,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                PlatformIconButton(
                  material: (_, __) => MaterialIconButtonData(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  cupertino: (_, __) => CupertinoIconButtonData(
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: onIncrease,
                  icon: Icon(
                    Icons.keyboard_arrow_right,
                    color: ColorPalette.primaryIconColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
