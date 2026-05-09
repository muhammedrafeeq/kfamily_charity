import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_utils.dart';
import 'profile.dart';

part 'withdrawal.freezed.dart';
part 'withdrawal.g.dart';

@freezed
class Withdrawal with _$Withdrawal {
  const factory Withdrawal({
    required String id,
    required double amount,
    required String reason,
    required String withdrawnBy,
    required DateTime createdAt,
    Profile? withdrawnByProfile,
  }) = _Withdrawal;

  factory Withdrawal.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalFromJson(snakeToCamel(json));
}
