import 'package:flutter/material.dart';

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
        color: Theme.of(context).backgroundColor,
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
                IconButton(
                  onPressed: onDecrease,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                IconButton(
                  onPressed: onIncrease,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(
                    Icons.keyboard_arrow_right,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
