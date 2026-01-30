class RealtimeDeviceData {
  final int deviceId;
  final double voltage;
  final double current;
  final double power;
  final double frequency;
  final double pf;
  final DateTime updatedAt;
  final double totalToday;
  final bool isOnline;
  final int upTime; // Stored as int seconds

  RealtimeDeviceData({
    required this.deviceId,
    required this.voltage,
    required this.current,
    required this.power,
    required this.frequency,
    required this.pf,
    required this.updatedAt,
    required this.totalToday,
    required this.isOnline,
    required this.upTime,
  });

  factory RealtimeDeviceData.fromJson(Map<String, dynamic> json) {
    return RealtimeDeviceData(
      deviceId: json['device_id'] as int,
      voltage: (json['voltage'] as num).toDouble(),
      current: (json['current'] as num).toDouble(),
      power: (json['power'] as num).toDouble(),
      frequency: (json['frequency'] as num).toDouble(),
      pf: (json['pf'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      totalToday: (json['total_today'] as num).toDouble(),
      isOnline: json['is_online'] as bool,
      // Parse string to int for up_time
      upTime: int.tryParse(json['up_time'].toString()) ?? 0,
    );
  }
}
