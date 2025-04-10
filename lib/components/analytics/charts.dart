import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsCharts extends StatelessWidget {
  final List<ChartData> userGrowthData = [
    ChartData(DateTime(2024, 1, 1), 50000, 1200, 30000),
    ChartData(DateTime(2024, 2, 1), 60000, 1500, 35000),
    ChartData(DateTime(2024, 3, 1), 75000, 1700, 45000),
    ChartData(DateTime(2024, 4, 1), 90000, 2000, 60000),
    ChartData(DateTime(2024, 5, 1), 95000, 2500, 70000),
  ];

  AnalyticsCharts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        _buildUsersOverTimeChart(),

        SizedBox(height: 16),
        _buildRevenueOverTimeChart(),
      ],
    );
  }

  /// 📊 Area Chart for Users Growth Over Time
  Widget _buildUsersOverTimeChart() {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(),
      primaryYAxis: NumericAxis(labelFormat: '{value}'),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<ChartData, DateTime>>[
        AreaSeries<ChartData, DateTime>(
          name: 'Followers',
          dataSource: userGrowthData,
          xValueMapper: (ChartData data, _) => data.date,
          yValueMapper: (ChartData data, _) => data.followers,
          gradient: _buildGradient(Colors.blue),
        ),
        AreaSeries<ChartData, DateTime>(
          name: 'Pledges',
          dataSource: userGrowthData,
          xValueMapper: (ChartData data, _) => data.date,
          yValueMapper: (ChartData data, _) => data.pledges,
          gradient: _buildGradient(Colors.green),
        ),
      ],
    );
  }

  /// 📈 Area Chart for Revenue Over Time
  Widget _buildRevenueOverTimeChart() {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(),
      primaryYAxis: NumericAxis(labelFormat: '\${value}'),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<ChartData, DateTime>>[
        AreaSeries<ChartData, DateTime>(
          name: 'Revenue',
          dataSource: userGrowthData,
          xValueMapper: (ChartData data, _) => data.date,
          yValueMapper: (ChartData data, _) => data.revenue,
          gradient: _buildGradient(Colors.purple),
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

/// 📊 Data model for the charts
class ChartData {
  final DateTime date;
  final int followers;
  final int pledges;
  final int revenue;

  ChartData(this.date, this.followers, this.pledges, this.revenue);
}
