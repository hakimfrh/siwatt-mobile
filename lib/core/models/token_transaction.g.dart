// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenTransaction _$TokenTransactionFromJson(Map<String, dynamic> json) =>
    TokenTransaction(
      id: (json['id'] as num).toInt(),
      deviceId: (json['device_id'] as num).toInt(),
      amountKwh: json['amount_kwh'] as String,
      price: json['price'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$TokenTransactionToJson(TokenTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device_id': instance.deviceId,
      'amount_kwh': instance.amountKwh,
      'price': instance.price,
      'created_at': instance.createdAt,
    };
