import 'package:body_weight_tracker/constants/strings.dart';
import 'package:body_weight_tracker/helpers/datetime_helper.dart';
import 'package:body_weight_tracker/models/weight_record_with_index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../body_weight_tracker_provider.dart';
import 'scrollable_date_bar.dart';
import 'body_weight_tracker_chart.dart';

class BodyWeightTrackerScreenBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final BodyWeightTrackerProvider bodyWeightAndStrengthTrackerProvider =
        Provider.of<BodyWeightTrackerProvider>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        children: [
          ScrollableDateBar(
            dateWidget: Selector<BodyWeightTrackerProvider, DateTimeRange>(
              selector: (context, bodyWeightAndStrengthTrackerProvider) =>
                  bodyWeightAndStrengthTrackerProvider.dateTimeRange,
              builder: (context, dateTimeRange, _) => Text(
                  "${DateTimeHelper.formatDateTimeToDayMonthYearString(dateTimeRange.start)} - ${DateTimeHelper.formatDateTimeToDayMonthYearString(
                    dateTimeRange.end,
                  )}",
                  style: Theme.of(context)
                      .textTheme
                      .headline1
                      ?.copyWith(fontSize: 16)),
            ),
            onDecrease: bodyWeightAndStrengthTrackerProvider.subtractQuarter,
            onIncrease: bodyWeightAndStrengthTrackerProvider.addQuarter,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 50,
                maxWidth: double.infinity,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text("Selected Date",
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(fontSize: 16)),
                      SizedBox(
                        height: 5,
                      ),
                      Selector<BodyWeightTrackerProvider,
                              WeightRecordWithIndex?>(
                          selector: (context, trackerProvider) =>
                              trackerProvider.highlightedRecordPoint,
                          builder: (context, highlightedDataPoint, _) {
                            if (highlightedDataPoint?.dateTime != null)
                              return Text(
                                DateTimeHelper.formatDateTimeToDDMMYYYYString(
                                    highlightedDataPoint?.dateTime),
                                style: Theme.of(context).textTheme.bodyText1,
                              );

                            return SizedBox();
                          }),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Selected Weight",
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(fontSize: 16)),
                      SizedBox(
                        height: 5,
                      ),
                      Selector<BodyWeightTrackerProvider,
                              WeightRecordWithIndex?>(
                          selector: (context, trackerProvider) =>
                              trackerProvider.highlightedRecordPoint,
                          builder: (context, highlightedDataPoint, _) {
                            if (highlightedDataPoint?.weight != null)
                              return Text(
                                "${highlightedDataPoint?.weight} kg",
                                style: Theme.of(context).textTheme.bodyText1,
                              );

                            return SizedBox();
                          }),
                    ],
                  ),
                  Column(
                    children: [
                      Text("Target",
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(fontSize: 16)),
                      SizedBox(
                        height: 5,
                      ),
                      Selector<BodyWeightTrackerProvider, double?>(
                          selector: (context, trackerProvider) =>
                              trackerProvider.target,
                          builder: (context, target, _) {
                            if (target != null)
                              return Text("$target kg",
                                  style: Theme.of(context).textTheme.bodyText1);

                            return SizedBox();
                          }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 2.1,
                  maxWidth: double.infinity,
                ),
                child: Selector<BodyWeightTrackerProvider, bool>(
                    selector: (context, bodyWeightAndStrengthTrackerProvider) =>
                        bodyWeightAndStrengthTrackerProvider.refreshDataFlag,
                    builder: (context, _, __) {
                      return FutureBuilder(
                        future:
                            bodyWeightAndStrengthTrackerProvider.fetchData(),
                        builder: (
                          context,
                          snapshot,
                        ) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          else {
                            if (snapshot.hasError) {
                              print(snapshot.error);
                              return Center(
                                child: Text(Strings.errorMessage),
                              );
                            } else {
                              return Selector<BodyWeightTrackerProvider, bool>(
                                selector: (context, weightTrackerProvider) =>
                                    weightTrackerProvider.refreshChartFlag,
                                builder: (context, _, __) {
                                  return BodyWeightTrackerChart();
                                },
                              );
                            }
                          }
                        },
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
