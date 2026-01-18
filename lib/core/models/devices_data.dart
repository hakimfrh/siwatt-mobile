import 'package:json_annotation/json_annotation.dart';

part 'devices_data.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DeviceData {
  final int id;
  final int deviceId;
  final DateTime datetime;
  final double voltage;
  final double current;
  final double power;
  final double energy;
  final double frequency;
  final double pf;
  final double energyHour;

  DeviceData({
    required this.id,
    required this.deviceId,
    required this.datetime,
    required this.voltage,
    required this.current,
    required this.power,
    required this.energy,
    required this.frequency,
    required this.pf,
    required this.energyHour,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) => _$DeviceDataFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceDataToJson(this);
}
