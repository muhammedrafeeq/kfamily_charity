import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_utils.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const Profile._();

  const factory Profile({
    required String id,
    @Default('') String fullName,
    String? phone,
    String? avatarUrl,
    @Default('member') String role,
    @Default(0) int memberNumber,
    @Default(true) bool isActive,
    required DateTime createdAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(snakeToCamel(json));

  bool get isAdmin => role == 'admin';
}
