import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siwatt_mobile/core/models/token_graph_data.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';

class TokenChartCard extends StatelessWidget {
  final String value;
  final String unit;
  final List<TokenGraphData> dataPoints;

  const TokenChartCard({super.key, required this.value, required this.unit, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (dataPoints.isEmpty) {
      return Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const Center(child: Text("Belum ada data grafik")),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sisa Token Listrik",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SiwattColors.textPrimary),
              ),
              Text(
                "$value $unit",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: SiwattColors.chartPower),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1, dashArray: [5, 5]),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(value.toStringAsFixed(0), style: const TextStyle(color: Colors.grey, fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < dataPoints.length) {
                          if (dataPoints.length > 7 && index % 2 != 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              DateFormat('d MMM').format(dataPoints[index].datetime),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
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
                extraLinesData: ExtraLinesData(
                  verticalLines: dataPoints.asMap().entries.where((e) => e.value.topup > 0).map((e) {
                    return VerticalLine(x: e.key.toDouble(), color: Colors.green, strokeWidth: 2, dashArray: [5, 5]);
                  }).toList(),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: dataPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.balance)).toList(),
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
                        colors: [SiwattColors.chartPower.withOpacity(0.5), SiwattColors.chartPower.withOpacity(0.0)],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        if (index < 0 || index >= dataPoints.length) return null;

                        final data = dataPoints[index];
                        return LineTooltipItem(
                          '',
                          const TextStyle(),
                          children: [
                            TextSpan(
                              text: 'Usage: ${data.usage.toStringAsFixed(2)} KwH\n',
                              style: textTheme.labelSmall?.copyWith(color: Colors.amber),
                            ),
                            if (data.topup != 0) ...[
                              TextSpan(
                                text: 'Topup: ${data.topup.toStringAsFixed(2)} KwH\n',
                                style: textTheme.labelSmall?.copyWith(color: Colors.green),
                              ),
                            ],
                            TextSpan(
                              text: 'Saldo: ${data.balance.toStringAsFixed(2)} KwH',
                              style: textTheme.labelSmall?.copyWith(color: Colors.blue),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
