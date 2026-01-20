
import 'package:json_annotation/json_annotation.dart';

part 'token_transaction.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TokenTransaction {
  int id;
  int deviceId;
  String type;
  String amountKwh;
  String price;
  String currentBalance;
  String finalBalance;
  String createdAt;

  TokenTransaction({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.amountKwh,
    required this.price,
    required this.currentBalance,
    required this.finalBalance,
    required this.createdAt,
  });

  factory TokenTransaction.fromJson(Map<String, dynamic> json) => _$TokenTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TokenTransactionToJson(this);
}