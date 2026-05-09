// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_contribution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentContributionImpl _$$PaymentContributionImplFromJson(
        Map<String, dynamic> json) =>
    _$PaymentContributionImpl(
      id: json['id'] as String,
      cycleId: json['cycleId'] as String,
      memberId: json['memberId'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      screenshotUrl: json['screenshotUrl'] as String?,
      screenshotPath: json['screenshotPath'] as String?,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      reviewedBy: json['reviewedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      member: json['member'] == null
          ? null
          : Profile.fromJson(json['member'] as Map<String, dynamic>),
      cycle: json['cycle'] == null
          ? null
          : PaymentCycle.fromJson(json['cycle'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PaymentContributionImplToJson(
        _$PaymentContributionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cycleId': instance.cycleId,
      'memberId': instance.memberId,
      'amount': instance.amount,
      'status': instance.status,
      'screenshotUrl': instance.screenshotUrl,
      'screenshotPath': instance.screenshotPath,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'reviewedBy': instance.reviewedBy,
      'rejectionReason': instance.rejectionReason,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'member': instance.member,
      'cycle': instance.cycle,
    };
