import 'package:body_weight_tracker/models/weight_record.dart';
import 'package:body_weight_tracker/models/weight_record_with_id.dart';
import 'package:body_weight_tracker/models/weight_record_with_index.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';

import '../body_weight_tracker_provider.dart';

class BodyWeightTrackerChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final BodyWeightTrackerProvider bodyWeightAndStrengthTrackerProvider =
        Provider.of<BodyWeightTrackerProvider>(context, listen: false);
    final List<charts.Series<WeightRecord, DateTime>> series = [
      charts.Series<WeightRecordWithId, DateTime>(
        id: "Weight",
        data: bodyWeightAndStrengthTrackerProvider.weightRecordPoints,
        domainFn: (WeightRecordWithId weight, _) => weight.dateTime,
        measureFn: (WeightRecordWithId weight, _) => weight.weight,
        displayName:
            bodyWeightAndStrengthTrackerProvider.weightRecordsDisplayName,
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
      ),
      charts.Series<WeightRecord, DateTime>(
        id: "Target",
        data: bodyWeightAndStrengthTrackerProvider.targetRecordPoints,
        domainFn: (WeightRecord target, _) => target.dateTime,
        measureFn: (WeightRecord target, _) => target.weight,
        displayName: bodyWeightAndStrengthTrackerProvider.targetDisplayName,
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
            final List<charts.SeriesDatum<dynamic>> selectedDatum =
                model.selectedDatum;
            if (selectedDatum.isNotEmpty) {
              if (selectedDatum.first.series.id != "Target" &&
                  selectedDatum.first.index != null) {
                bodyWeightAndStrengthTrackerProvider.setHighlightedDataPoint =
                    WeightRecordWithIndex(
                  dateTime: selectedDatum.first.datum.dateTime,
                  weight: selectedDatum.first.datum.weight,
                  index: selectedDatum.first.index!,
                );
              } else {
                bodyWeightAndStrengthTrackerProvider.unhighlightDataPoint();
              }
            }
          },
        )
      ],
      domainAxis: new charts.DateTimeAxisSpec(
        tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
          day: new charts.TimeFormatterSpec(
            format: 'dd',
            transitionFormat: 'dd MMM',
          ),
        ),
        viewport: charts.DateTimeExtents(
          start: bodyWeightAndStrengthTrackerProvider.dateTimeRange.start,
          end: bodyWeightAndStrengthTrackerProvider.dateTimeRange.end,
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
        charts.PanAndZoomBehavior(),
      ],
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
          desiredMinTickCount: 5,
          desiredMaxTickCount: 10,
        ),
        showAxisLine: true,
        viewport: charts.NumericExtents(
          bodyWeightAndStrengthTrackerProvider.weightPointsLen > 0 ||
                  bodyWeightAndStrengthTrackerProvider.targetPointsLen > 0
              ? bodyWeightAndStrengthTrackerProvider.minWeight * 0.8
              : 0,
          bodyWeightAndStrengthTrackerProvider.weightPointsLen > 0 ||
                  bodyWeightAndStrengthTrackerProvider.targetPointsLen > 0
              ? bodyWeightAndStrengthTrackerProvider.maxWeight * 1.2
              : 100,
        ),
      ),
      dateTimeFactory: charts.LocalDateTimeFactory(),
    );
  }
}
