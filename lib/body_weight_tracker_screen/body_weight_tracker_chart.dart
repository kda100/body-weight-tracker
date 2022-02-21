import 'package:body_weight_tracker/models/weight_record.dart';
import 'package:body_weight_tracker/models/weight_record_with_id.dart';
import 'package:body_weight_tracker/models/weight_record_with_index.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';

import '../body_weight_tracker_provider.dart';

///Interactive chart to display user weight records and target.
///The weight records is a line of connecting points from the weight record with the smallest date to the highest,
///the target is a continuous straight line with two connecting points.

class BodyWeightTrackerChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final BodyWeightTrackerProvider bodyWeightTrackerProvider =
        Provider.of<BodyWeightTrackerProvider>(context, listen: false);
    //series for weight records showing users progress over time.
    final List<charts.Series<WeightRecord, DateTime>> series = [
      charts.Series<WeightRecordWithId, DateTime>(
        id: "Weight",
        data: bodyWeightTrackerProvider.weightRecordPoints,
        domainFn: (WeightRecordWithId weight, _) => weight.dateTime,
        measureFn: (WeightRecordWithId weight, _) => weight.weight,
        displayName: "Weight",
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
      ),
      //Series to display the target to the user.
      charts.Series<WeightRecord, DateTime>(
        id: "Target",
        data: bodyWeightTrackerProvider.targetRecordPoints,
        domainFn: (WeightRecord target, _) => target.dateTime,
        measureFn: (WeightRecord target, _) => target.weight,
        displayName: "Target",
        colorFn: (_, __) => charts.MaterialPalette.black,
      ),
    ];
    return charts.TimeSeriesChart(
      series,
      defaultRenderer: charts.LineRendererConfig(includePoints: true),
      customSeriesRenderers: [
        charts.PointRendererConfig(customRendererId: "customPoint"),
      ],
      selectionModels: [
        charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          changedListener: (charts.SelectionModel model) {
            // controls the selection of the highlighted point.
            final List<charts.SeriesDatum<dynamic>> selectedDatum =
                model.selectedDatum;
            if (selectedDatum.isNotEmpty) {
              if (selectedDatum.first.series.id != "Target" &&
                  selectedDatum.first.index != null) {
                // prevents target points from being highlighted points.
                bodyWeightTrackerProvider.setHighlightedDataPoint =
                    WeightRecordWithIndex(
                  dateTime: selectedDatum.first.datum.dateTime,
                  weight: selectedDatum.first.datum.weight,
                  index: selectedDatum.first.index!,
                );
              } else {
                // removes highlighted point if invalid point is selected (target or null).
                bodyWeightTrackerProvider.unhighlightDataPoint();
              }
            }
          },
        )
      ],
      domainAxis: new charts.DateTimeAxisSpec(
        // formats x-axis to use date objects.
        tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
          day: new charts.TimeFormatterSpec(
            format: 'dd',
            transitionFormat: 'dd MMM',
          ),
        ),
        viewport: charts.DateTimeExtents(
          start: bodyWeightTrackerProvider.dateTimeRange.start,
          end: bodyWeightTrackerProvider.dateTimeRange.end,
        ),
      ),
      behaviors: [
        charts.SeriesLegend(
          position: charts.BehaviorPosition.top,
          outsideJustification: charts.OutsideJustification.middleDrawArea,
          horizontalFirst: false,
          desiredMaxRows: 1,
          entryTextStyle: charts.TextStyleSpec(
            color: charts.Color.black,
          ),
          cellPadding: EdgeInsets.only(
            right: 8,
            left: 8,
          ),
        ),
        charts.LinePointHighlighter(),
        charts
            .PanAndZoomBehavior(), // allows chart to be zoomed in and out interactively.
      ],
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
          desiredMinTickCount: 5,
          desiredMaxTickCount: 10,
        ),
        showAxisLine: true,
        viewport: charts.NumericExtents(
          //creates default weight limits when no weight records exist (0, 100).
          //when weight records exist, weight limits are (0.8 * minWeight, 1.2 * maxWeight)
          bodyWeightTrackerProvider.weightRecordsLen > 0 ||
                  bodyWeightTrackerProvider.targetWeightRecordsLen > 0
              ? bodyWeightTrackerProvider.minWeight * 0.8
              : 0,
          bodyWeightTrackerProvider.weightRecordsLen > 0 ||
                  bodyWeightTrackerProvider.targetWeightRecordsLen > 0
              ? bodyWeightTrackerProvider.maxWeight * 1.2
              : 100,
        ),
      ),
      dateTimeFactory: charts.LocalDateTimeFactory(),
    );
  }
}
