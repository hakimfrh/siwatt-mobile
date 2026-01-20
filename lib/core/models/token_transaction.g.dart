// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenTransaction _$TokenTransactionFromJson(Map<String, dynamic> json) =>
    TokenTransaction(
      id: (json['id'] as num).toInt(),
      deviceId: (json['device_id'] as num).toInt(),
      type: json['type'] as String,
      amountKwh: json['amount_kwh'] as String,
      price: json['price'] as String,
      currentBalance: json['current_balance'] as String,
      finalBalance: json['final_balance'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$TokenTransactionToJson(TokenTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device_id': instance.deviceId,
      'type': instance.type,
      'amount_kwh': instance.amountKwh,
      'price': instance.price,
      'current_balance': instance.currentBalance,
      'final_balance': instance.finalBalance,
      'created_at': instance.createdAt,
    };
