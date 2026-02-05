import 'package:json_annotation/json_annotation.dart';

part 'realtime_device_data.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RealtimeDeviceData {
  final int deviceId;
  final double voltage;
  final double current;
  final double power;
  final double frequency;
  final double pf;
  final DateTime? updatedAt;
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
     this.updatedAt,
    required this.totalToday,
    required this.isOnline,
    required this.upTime,
  });

  factory RealtimeDeviceData.fromJson(Map<String, dynamic> json) => _$RealtimeDeviceDataFromJson(json);
  Map<String, dynamic> toJson() => _$RealtimeDeviceDataToJson(this);

}
