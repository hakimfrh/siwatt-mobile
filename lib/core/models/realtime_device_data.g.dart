// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_device_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RealtimeDeviceData _$RealtimeDeviceDataFromJson(Map<String, dynamic> json) =>
    RealtimeDeviceData(
      deviceId: (json['device_id'] as num).toInt(),
      voltage: (json['voltage'] as num).toDouble(),
      current: (json['current'] as num).toDouble(),
      power: (json['power'] as num).toDouble(),
      frequency: (json['frequency'] as num).toDouble(),
      pf: (json['pf'] as num).toDouble(),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      totalToday: (json['total_today'] as num).toDouble(),
      isOnline: json['is_online'] as bool,
      upTime: (json['up_time'] as num).toInt(),
    );

Map<String, dynamic> _$RealtimeDeviceDataToJson(RealtimeDeviceData instance) =>
    <String, dynamic>{
      'device_id': instance.deviceId,
      'voltage': instance.voltage,
      'current': instance.current,
      'power': instance.power,
      'frequency': instance.frequency,
      'pf': instance.pf,
      'updated_at': instance.updatedAt?.toIso8601String(),
      'total_today': instance.totalToday,
      'is_online': instance.isOnline,
      'up_time': instance.upTime,
    };
