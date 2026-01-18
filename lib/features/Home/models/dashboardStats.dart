import 'package:json_annotation/json_annotation.dart';

part 'dashboardStats.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DashboardStats {
  final double avgUsageToday;
  final double tokenBalance;
  final int estimatedDays;

  DashboardStats({
    required this.avgUsageToday,
    required this.tokenBalance,
    required this.estimatedDays,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardStatsToJson(this);
}