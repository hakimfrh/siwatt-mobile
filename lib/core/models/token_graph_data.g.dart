// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_graph_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenGraphData _$TokenGraphDataFromJson(Map<String, dynamic> json) =>
    TokenGraphData(
      datetime: DateTime.parse(json['datetime'] as String),
      usage: (json['usage'] as num).toDouble(),
      topup: (json['topup'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      type: json['type'] as String,
    );

Map<String, dynamic> _$TokenGraphDataToJson(TokenGraphData instance) =>
    <String, dynamic>{
      'datetime': instance.datetime.toIso8601String(),
      'usage': instance.usage,
      'topup': instance.topup,
      'balance': instance.balance,
      'type': instance.type,
    };
