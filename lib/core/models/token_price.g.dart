// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenPrice _$TokenPriceFromJson(Map<String, dynamic> json) => TokenPrice(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  details: json['details'] as String,
  pricePerKwh: (json['price_per_kwh'] as num).toDouble(),
  lastUpdate: DateTime.parse(json['last_update'] as String),
);

Map<String, dynamic> _$TokenPriceToJson(TokenPrice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'details': instance.details,
      'price_per_kwh': instance.pricePerKwh,
      'last_update': instance.lastUpdate.toIso8601String(),
    };
