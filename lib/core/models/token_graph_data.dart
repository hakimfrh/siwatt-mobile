
import 'package:json_annotation/json_annotation.dart';

part 'token_graph_data.g.dart';
@JsonSerializable(fieldRename: FieldRename.snake)
class TokenGraphData {
  final DateTime datetime;
  final double usage;
  final double topup;
  final double balance;
  final String type;

  TokenGraphData({
    required this.datetime,
    required this.usage,
    required this.topup,
    required this.balance,
    required this.type
  });

  factory TokenGraphData.fromJson(Map<String, dynamic> json) => _$TokenGraphDataFromJson(json);
  Map<String, dynamic> toJson() => _$TokenGraphDataToJson(this);
}
