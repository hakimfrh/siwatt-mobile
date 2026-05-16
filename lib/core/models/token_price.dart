import 'package:json_annotation/json_annotation.dart';

part 'token_price.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TokenPrice {
  final int id;
  final String code;
  final String details;
  final double pricePerKwh;
  final DateTime lastUpdate;

  TokenPrice({
    required this.id,
    required this.code,
    required this.details,
    required this.pricePerKwh,
    required this.lastUpdate,
  });

  factory TokenPrice.fromJson(Map<String, dynamic> json) =>
      _$TokenPriceFromJson(json);

  Map<String, dynamic> toJson() => _$TokenPriceToJson(this);
}
