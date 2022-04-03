import 'package:body_weight_tracker/constants/color_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      padding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: 6.h,
      ),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.2),
        ),
      ),
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
                    constraints: BoxConstraints(),
                  ),
                  cupertino: (_, __) => CupertinoIconButtonData(
                    minSize: 0,
                  ),
                  onPressed: onDecrease,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    color: ColorPalette.primaryIconColor,
                  ),
                ),
                SizedBox(
                  width: 20.w,
                ),
                PlatformIconButton(
                  material: (_, __) => MaterialIconButtonData(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    constraints: BoxConstraints(),
                  ),
                  cupertino: (_, __) => CupertinoIconButtonData(
                    minSize: 0,
                  ),
                  padding: EdgeInsets.zero,
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
