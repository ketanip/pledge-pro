import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsCharts extends StatefulWidget {
  final Map<DateTime, int> donationsChartData;
  final Map<DateTime, int> subscriptionChartData;

  const AnalyticsCharts({
    super.key,
    required this.donationsChartData,
    required this.subscriptionChartData,
  });

  @override
  State<AnalyticsCharts> createState() => _AnalyticsChartsState();
}

/// 📊 Data model for the charts
class ChartData {
  final DateTime date;
  final int value;

  ChartData(this.date, this.value);
}

/// Converts a Map<DateTime, int> to a sorted list of ChartData
List<ChartData> convertMapToChartData(Map<DateTime, int> map) {
  return map.entries.map((entry) => ChartData(entry.key, entry.value)).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}

class _AnalyticsChartsState extends State<AnalyticsCharts> {
  late List<ChartData> _donationsChartData;
  late List<ChartData> _subscriptionChartData;

  @override
  void initState() {
    super.initState();
    _updateChartData();
  }

  @override
  void didUpdateWidget(covariant AnalyticsCharts oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if data actually changed
    if (widget.donationsChartData != oldWidget.donationsChartData ||
        widget.subscriptionChartData != oldWidget.subscriptionChartData) {
      _updateChartData();
    }
  }

  void _updateChartData() {
    _donationsChartData = convertMapToChartData(widget.donationsChartData);
    _subscriptionChartData = convertMapToChartData(
      widget.subscriptionChartData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildChart("Donations", _donationsChartData, Colors.purple, "₹"),

        const SizedBox(height: 16),
        _buildChart(
          "New Pledges (Subscribers)",
          _subscriptionChartData,
          Colors.blueAccent,
          "",
        ),
      ],
    );
  }

  /// 📈 Area Chart for Revenue Over Time
  Widget _buildChart(
    String title,
    List<ChartData> data,
    Color color,
    String precedeValue,
  ) {
    if (data.isEmpty) {
      return Text(
        '$title data not available',
        style: const TextStyle(color: Colors.grey),
      );
    }

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(),
      primaryYAxis: NumericAxis(labelFormat: '$precedeValue{value}'),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<ChartData, DateTime>>[
        AreaSeries<ChartData, DateTime>(
          name: title,
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.date.toLocal(),
          yValueMapper: (ChartData data, _) => data.value,
          gradient: _buildGradient(color),
        ),
      ],
    );
  }

  /// 🎨 Helper method to create a gradient for area charts
  LinearGradient _buildGradient(Color color) {
    return LinearGradient(
      colors: [color.withAlpha(153), color.withAlpha(26)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
