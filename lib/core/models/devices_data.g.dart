// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceData _$DeviceDataFromJson(Map<String, dynamic> json) => DeviceData(
  id: (json['id'] as num).toInt(),
  deviceId: (json['device_id'] as num).toInt(),
  datetime: DateTime.parse(json['datetime'] as String),
  voltage: (json['voltage'] as num).toDouble(),
  current: (json['current'] as num).toDouble(),
  power: (json['power'] as num).toDouble(),
  energy: (json['energy'] as num).toDouble(),
  frequency: (json['frequency'] as num).toDouble(),
  pf: (json['pf'] as num).toDouble(),
  energyHour: (json['energy_hour'] as num).toDouble(),
);

Map<String, dynamic> _$DeviceDataToJson(DeviceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device_id': instance.deviceId,
      'datetime': instance.datetime.toIso8601String(),
      'voltage': instance.voltage,
      'current': instance.current,
      'power': instance.power,
      'energy': instance.energy,
      'frequency': instance.frequency,
      'pf': instance.pf,
      'energy_hour': instance.energyHour,
    };
