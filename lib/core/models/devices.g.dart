// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
  id: (json['id'] as num).toInt(),
  deviceCode: json['device_code'] as String,
  location: json['location'] as String,
  isActive: json['is_active'] as bool,
  deviceName: json['device_name'] as String,
  tokenBalance: (json['token_balance'] as num).toDouble(),
  upTime: (json['up_time'] as num).toInt(),
  lastOnline: json['last_online'] == null
      ? null
      : DateTime.parse(json['last_online'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'id': instance.id,
  'device_code': instance.deviceCode,
  'location': instance.location,
  'is_active': instance.isActive,
  'device_name': instance.deviceName,
  'token_balance': instance.tokenBalance,
  'up_time': instance.upTime,
  'last_online': instance.lastOnline?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};
