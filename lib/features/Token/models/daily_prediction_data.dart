/// Model untuk satu titik prediksi harian token listrik.
/// [energyDay] = saldo berjalan (running balance) setelah hari ini.
/// [usage]     = estimasi konsumsi harian (energy_day dari API).
class DailyPredictionPoint {
  final DateTime date;
  final double energyDay; // saldo berjalan
  final double usage;     // konsumsi harian prediksi

  DailyPredictionPoint({
    required this.date,
    required this.energyDay,
    this.usage = 0.0,
  });

  factory DailyPredictionPoint.fromJson(Map<String, dynamic> json) {
    return DailyPredictionPoint(
      date: DateTime.parse(json['date']),
      energyDay: (json['energy_day'] as num).toDouble(),
    );
  }
}
