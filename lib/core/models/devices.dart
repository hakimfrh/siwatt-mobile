import 'package:json_annotation/json_annotation.dart';

import 'token_price.dart';

part 'devices.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Device {
  final int id;
  final String deviceCode;
  final String deviceName;
  final String location;
  final int? priceId;
  final double priceTax;
  final double tokenBalance;
  final bool isActive;
  final int upTime;
  final DateTime? lastOnline;
  final DateTime createdAt;
  final TokenPrice? tokenPrice;

  Device({
    required this.id,
    required this.deviceCode,
    required this.deviceName,
    required this.location,
    this.priceId,
    required this.priceTax,
    required this.tokenBalance,
    required this.isActive,
    required this.upTime,
    this.lastOnline,
    required this.createdAt,
    this.tokenPrice,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}
