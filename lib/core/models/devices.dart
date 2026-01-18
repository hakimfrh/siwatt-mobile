import 'package:json_annotation/json_annotation.dart';

part 'devices.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Device {
  final int id;
  final String deviceCode;
  final String location;
  final bool isActive;
  final String deviceName;
  final double tokenBalance;
  final int upTime;
  final DateTime? lastOnline;
  final DateTime createdAt;

  Device({
    required this.id,
    required this.deviceCode,
    required this.location,
    required this.isActive,
    required this.deviceName,
    required this.tokenBalance,
    required this.upTime,
    this.lastOnline,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}
