import 'package:json_annotation/json_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'user_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String fullName;
  @HiveField(2)
  final String username;
  @HiveField(3)
  final String email;

  User({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
