import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';

class TokenChartCard extends StatelessWidget {
  final String value;
  final String unit;
  final List<double> dataPoints;

  const TokenChartCard({
    super.key,
    required this.value,
    required this.unit,
    required this.dataPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sisa Token Listrik",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SiwattColors.textPrimary,
                ),
              ),
              Text(
                "$value $unit",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SiwattColors.chartPower, // Orange color to match image
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30, // Space for Y axis labels
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          "", // Hide Y axis text to stay clean like design or empty
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true, // Show X axis ticks
                        interval: 2,
                        getTitlesWidget: (initialValue, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text("", // Empty X axis labels
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                          );
                        }),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.black.withOpacity(0.5)),
                    bottom: BorderSide(color: Colors.black.withOpacity(0.5)),
                  ),
                ),
                minX: 0,
                maxX: (dataPoints.length - 1).toDouble(),
                minY: dataPoints.reduce((a, b) => a < b ? a : b) * 0.9,
                maxY: dataPoints.reduce((a, b) => a > b ? a : b) * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: dataPoints
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: SiwattColors.chartPower,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          SiwattColors.chartPower.withOpacity(0.5),
                          SiwattColors.chartPower.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
