import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_utils.dart';

part 'monthly_summary.freezed.dart';
part 'monthly_summary.g.dart';

@freezed
class MonthlySummary with _$MonthlySummary {
  const MonthlySummary._();

  const factory MonthlySummary({
    required String cycleId,
    required int year,
    required int month,
    required String status,
    @Default(0) int paidCount,
    @Default(0) int pendingCount,
    @Default(0) int rejectedCount,
    @Default(0.0) double totalCollected,
    @Default(0) int totalMembers,
  }) = _MonthlySummary;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) =>
      _$MonthlySummaryFromJson(snakeToCamel(json));

  double get collectionRate => totalMembers > 0 ? paidCount / totalMembers : 0;
  int get outstandingCount => totalMembers - paidCount;
}
