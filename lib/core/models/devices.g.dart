// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
  id: (json['id'] as num).toInt(),
  deviceCode: json['device_code'] as String,
  deviceName: json['device_name'] as String,
  location: json['location'] as String,
  priceId: (json['price_id'] as num?)?.toInt(),
  priceTax: (json['price_tax'] as num).toDouble(),
  tokenBalance: (json['token_balance'] as num).toDouble(),
  isActive: json['is_active'] as bool,
  upTime: (json['up_time'] as num).toInt(),
  lastOnline: json['last_online'] == null
      ? null
      : DateTime.parse(json['last_online'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  tokenPrice: json['token_price'] == null
      ? null
      : TokenPrice.fromJson(json['token_price'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'id': instance.id,
  'device_code': instance.deviceCode,
  'device_name': instance.deviceName,
  'location': instance.location,
  'price_id': instance.priceId,
  'price_tax': instance.priceTax,
  'token_balance': instance.tokenBalance,
  'is_active': instance.isActive,
  'up_time': instance.upTime,
  'last_online': instance.lastOnline?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'token_price': instance.tokenPrice,
};
