class TokenGraphData {
  final DateTime datetime;
  final double usage;
  final double topup;
  final double balance;

  TokenGraphData({
    required this.datetime,
    required this.usage,
    required this.topup,
    required this.balance,
  });

  factory TokenGraphData.fromJson(Map<String, dynamic> json) {
    return TokenGraphData(
      datetime: DateTime.parse(json['datetime']),
      usage: (json['usage'] as num).toDouble(),
      topup: (json['topup'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
    );
  }
}
