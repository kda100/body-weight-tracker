import 'package:body_weight_tracker/body_weight_tracker_screen/chart_data.dart';
import 'package:body_weight_tracker/constants/strings.dart';
import 'package:body_weight_tracker/helpers/datetime_helper.dart';
import 'package:body_weight_tracker/models/weight_record_with_index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/text_styles.dart';
import '../providers/body_weight_tracker_provider.dart';
import 'scrollable_date_bar.dart';
import 'body_weight_tracker_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///Body of the main screen that contains the chart for the body weight tracker
///and the scrollable date bar to change the date range the body weight tracker displays.

class BodyWeightTrackerScreenBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final BodyWeightTrackerProvider bodyWeightTrackerProvider =
        Provider.of<BodyWeightTrackerProvider>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        children: [
          ScrollableDateBar(
            //changes date displayed in scrollable date bar when the date range changes.
            dateWidget: Selector<BodyWeightTrackerProvider, DateTimeRange>(
              selector: (context, bodyWeightAndStrengthTrackerProvider) =>
                  bodyWeightAndStrengthTrackerProvider.dateTimeRange,
              builder: (context, dateTimeRange, _) => Text(
                "${DateTimeHelper.formatDateTimeToDayMonthYearString(dateTimeRange.start)} - ${DateTimeHelper.formatDateTimeToDayMonthYearString(
                  dateTimeRange.end,
                )}",
                style: TextStyles.customHeading,
              ),
            ),
            onDecrease: bodyWeightTrackerProvider.subtractQuarter,
            onIncrease: bodyWeightTrackerProvider.addQuarter,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: double.infinity,
                maxHeight: 50.h,
                minHeight: 50.h,
              ),
              child: Row(
                // contains target and hte highlighted weight record's date and weight.
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChartData(
                    header: "Selected Date",
                    data: Selector<BodyWeightTrackerProvider,
                        WeightRecordWithIndex?>(
                      //changes when the highlighted weight record changes.
                      selector: (context, trackerProvider) =>
                          trackerProvider.highlightedRecordPoint,
                      builder: (context, highlightedDataPoint, _) {
                        if (highlightedDataPoint?.dateTime != null)
                          return Text(
                            DateTimeHelper.formatDateTimeToDDMMYYYYString(
                                highlightedDataPoint?.dateTime),
                          );

                        return SizedBox();
                      },
                    ),
                  ),
                  ChartData(
                    header: "Selected Weight",
                    data: Selector<BodyWeightTrackerProvider,
                        WeightRecordWithIndex?>(
                      selector: (context, trackerProvider) =>
                          trackerProvider.highlightedRecordPoint,
                      builder: (context, highlightedDataPoint, _) {
                        //changes when the highlighted weight record changes.
                        if (highlightedDataPoint?.weight != null)
                          return Text(
                            "${highlightedDataPoint?.weight} kg",
                          );
                        return SizedBox();
                      },
                    ),
                  ),
                  ChartData(
                    header: "Target",
                    data: Selector<BodyWeightTrackerProvider, double?>(
                      selector: (context, trackerProvider) =>
                          trackerProvider.target,
                      builder: (context, target, _) {
                        //changes when the target changes.
                        if (target != null)
                          return Text(
                            "$target kg",
                          );

                        return SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: Selector<BodyWeightTrackerProvider, bool>(
                  selector: (context, bodyWeightAndStrengthTrackerProvider) =>
                      bodyWeightAndStrengthTrackerProvider.refreshDataFlag,
                  builder: (context, _, __) {
                    ///The body weight tracker rebuilds and queries Cloud Firestore Weight Records Col again when the refreshDataFlag changes.
                    ///This happens when user scrolls the date bar and changes the date range.
                    ///The tracker is built after data has been fetched from the database.
                    return FutureBuilder(
                      future: bodyWeightTrackerProvider.fetchData(),
                      builder: (
                        context,
                        snapshot,
                      ) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        else {
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return Center(
                              child: Text(
                                Strings.errorMessage,
                              ),
                            );
                          } else {
                            return Selector<BodyWeightTrackerProvider, bool>(
                              selector: (context, weightTrackerProvider) =>
                                  weightTrackerProvider.refreshChartFlag,
                              builder: (context, _, __) {
                                ///Chart rebuilds when the refreshChartFlag is changed
                                ///The happens when user adds new weight record to a date that is contained within current the date range.
                                ///This is so data is reflected instantly in chart without having to get data from firebase again.
                                return BodyWeightTrackerChart();
                              },
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
