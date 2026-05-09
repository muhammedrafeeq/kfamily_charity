import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/utils/json_utils.dart';
import 'profile.dart';
import 'payment_cycle.dart';

part 'payment_contribution.freezed.dart';
part 'payment_contribution.g.dart';

@freezed
class PaymentContribution with _$PaymentContribution {
  const PaymentContribution._();

  const factory PaymentContribution({
    required String id,
    required String cycleId,
    required String memberId,
    @Default(0.0) double amount,
    @Default('pending') String status,
    String? screenshotUrl,
    String? screenshotPath,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? rejectionReason,
    String? notes,
    required DateTime createdAt,
    Profile? member,
    PaymentCycle? cycle,
  }) = _PaymentContribution;

  factory PaymentContribution.fromJson(Map<String, dynamic> json) =>
      _$PaymentContributionFromJson(snakeToCamel(json));

  bool get isPending => status == 'pending';
  bool get isSubmitted => status == 'submitted';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get hasScreenshot => screenshotUrl != null || screenshotPath != null;
  bool get canResubmit => isPending || isRejected;
}
