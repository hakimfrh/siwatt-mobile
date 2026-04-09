import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siwatt_mobile/core/models/token_graph_data.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/token/models/daily_prediction_data.dart';

class TokenChartCard extends StatelessWidget {
  final String value;
  final String unit;
  final List<TokenGraphData> dataPoints;

  /// Titik prediksi saldo per hari ke depan.
  /// Tiap [DailyPredictionPoint.energyDay] sudah berisi SALDO BERJALAN (bukan
  /// konsumsi), dihitung di controller. Boleh kosong.
  final List<DailyPredictionPoint> predictionPoints;

  const TokenChartCard({
    super.key,
    required this.value,
    required this.unit,
    required this.dataPoints,
    this.predictionPoints = const [],
  });

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

    // ── Spots data aktual ──────────────────────────────────────────────────
    final actualSpots = dataPoints
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.balance))
        .toList();

    // ── Spots prediksi ──────────────────────────────────────────────────────
    // X prediksi dimulai setelah indeks terakhir data aktual.
    // Titik sambungan: x_start = indeks terakhir aktual (agar garis menyambung).
    final hasPrediction = predictionPoints.isNotEmpty;
    List<FlSpot> predSpots = [];
    if (hasPrediction) {
      final lastActualIndex = (dataPoints.length - 1).toDouble();
      final lastActualBalance = dataPoints.last.balance;
      // Titik pertama = ujung data aktual (sambungan grafik)
      predSpots.add(FlSpot(lastActualIndex, lastActualBalance));
      for (int i = 0; i < predictionPoints.length; i++) {
        predSpots.add(FlSpot(lastActualIndex + i + 1, predictionPoints[i].energyDay));
      }
    }

    // ── Jumlah total x-axis ──────────────────────────────────────────────
    final totalPoints = hasPrediction
        ? dataPoints.length + predictionPoints.length
        : dataPoints.length;
    final maxX = (totalPoints - 1).toDouble();

    // ── Label tanggal gabungan untuk bottom axis ─────────────────────────
    // index 0..(dataPoints.length-1) → tanggal dari dataPoints
    // index dataPoints.length..totalPoints-1 → tanggal dari predictionPoints
    DateTime? _labelDate(int index) {
      if (index < dataPoints.length) return dataPoints[index].datetime;
      final predIndex = index - dataPoints.length;
      if (predIndex < predictionPoints.length) return predictionPoints[predIndex].date;
      return null;
    }

    // ── maxY mencakup range data aktual + prediksi ───────────────────────
    double maxY = actualSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    if (hasPrediction) {
      final predMax = predSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      if (predMax > maxY) maxY = predMax;
    }
    maxY = maxY * 1.1; // 10% padding atas

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
          if (hasPrediction) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                _dashLegend(Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  'Estimasi sisa token (LSTM)',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
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
                        if (index < 0 || index >= totalPoints) return const SizedBox.shrink();
                        // Sembunyikan label terlalu rapat jika banyak data
                        if (totalPoints > 7 && index % 2 != 0) return const SizedBox.shrink();
                        final date = _labelDate(index);
                        if (date == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            DateFormat('d MMM').format(date),
                            style: TextStyle(
                              fontSize: 10,
                              // Label prediksi sedikit lebih pudar
                              color: index >= dataPoints.length ? Colors.grey.shade400 : Colors.grey,
                            ),
                          ),
                        );
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
                extraLinesData: ExtraLinesData(
                  verticalLines: dataPoints.asMap().entries.where((e) => e.value.topup > 0).map((e) {
                    return VerticalLine(
                      x: e.key.toDouble(),
                      color: e.value.type == "topup" ? Colors.green : Colors.amber,
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    );
                  }).toList(),
                ),
                lineBarsData: [
                  // ── Garis data aktual ──────────────────────────────────
                  LineChartBarData(
                    spots: actualSpots,
                    isCurved: true,
                    preventCurveOverShooting: true,
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
                  // ── Garis prediksi putus-putus abu-abu ────────────────
                  if (hasPrediction)
                    LineChartBarData(
                      spots: predSpots,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: Colors.grey.shade400,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        final isPrediction = touchedSpot.barIndex == 1;

                        if (isPrediction) {
                          // Prediksi: cari date dari predictionPoints
                          // predSpots[0] adalah titik sambungan (= last actual)
                          final predIndex = index - dataPoints.length;
                          if (predIndex < 0 || predIndex >= predictionPoints.length) return null;
                          final pt = predictionPoints[predIndex];
                          return LineTooltipItem(
                            '',
                            const TextStyle(),
                            children: [
                              TextSpan(
                                text: '${DateFormat('d MMM').format(pt.date)}\n',
                                style: textTheme.labelSmall?.copyWith(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: 'Est. Usage: ${pt.usage.toStringAsFixed(2)} KwH\n',
                                style: textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
                              ),
                              TextSpan(
                                text: 'Est. Saldo: ${pt.energyDay.toStringAsFixed(2)} KwH',
                                style: textTheme.labelSmall?.copyWith(color: Colors.grey.shade500),
                              ),
                            ],
                          );
                        }

                        // Data aktual
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
                            if (data.type == "topup") ...[
                              TextSpan(
                                text: 'Topup: ${data.topup.toStringAsFixed(2)} KwH\n',
                                style: textTheme.labelSmall?.copyWith(color: Colors.green),
                              ),
                            ],
                            if (data.type == "correction") ...[
                              TextSpan(
                                text: 'Change: ${data.usage.toStringAsFixed(2)} KwH\n',
                                style: textTheme.labelSmall?.copyWith(color: Colors.amber),
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

  // Helper: tampilan legend garis putus-putus
  Widget _dashLegend(Color color) {
    return Row(
      children: List.generate(3, (i) => Container(
        width: 5,
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1)),
      )),
    );
  }
}
