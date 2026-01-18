// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboardStats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    DashboardStats(
      avgUsageToday: (json['avg_usage_today'] as num).toDouble(),
      tokenBalance: (json['token_balance'] as num).toDouble(),
      estimatedDays: (json['estimated_days'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardStatsToJson(DashboardStats instance) =>
    <String, dynamic>{
      'avg_usage_today': instance.avgUsageToday,
      'token_balance': instance.tokenBalance,
      'estimated_days': instance.estimatedDays,
    };
