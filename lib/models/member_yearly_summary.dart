import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_utils.dart';

part 'member_yearly_summary.freezed.dart';
part 'member_yearly_summary.g.dart';

@freezed
class MemberYearlySummary with _$MemberYearlySummary {
  const MemberYearlySummary._();

  const factory MemberYearlySummary({
    required String memberId,
    @Default('') String fullName,
    @Default(0) int memberNumber,
    required int year,
    @Default(0) int monthsPaid,
    @Default(0) int monthsPending,
    @Default(0.0) double totalPaid,
  }) = _MemberYearlySummary;

  factory MemberYearlySummary.fromJson(Map<String, dynamic> json) =>
      _$MemberYearlySummaryFromJson(snakeToCamel(json));

  double get reliabilityRate => monthsPaid / 12;
}
