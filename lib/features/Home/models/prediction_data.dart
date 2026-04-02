class PredictionPoint {
  final DateTime datetime;
  final double energyHour;

  PredictionPoint({
    required this.datetime,
    required this.energyHour,
  });

  factory PredictionPoint.fromJson(Map<String, dynamic> json) {
    return PredictionPoint(
      datetime: DateTime.parse(json['datetime']),
      energyHour: (json['energy_hour'] as num).toDouble(),
    );
  }
}

class PredictionData {
  final List<PredictionPoint> predictions;

  PredictionData({required this.predictions});

  factory PredictionData.fromJson(Map<String, dynamic> json) {
    final predList = json['data']['prediction']['predictions'] as List<dynamic>;
    return PredictionData(
      predictions: predList.map((e) => PredictionPoint.fromJson(e)).toList(),
    );
  }
}
