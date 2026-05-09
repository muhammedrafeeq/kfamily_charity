// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_yearly_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemberYearlySummaryImpl _$$MemberYearlySummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$MemberYearlySummaryImpl(
      memberId: json['memberId'] as String,
      fullName: json['fullName'] as String? ?? '',
      memberNumber: (json['memberNumber'] as num?)?.toInt() ?? 0,
      year: (json['year'] as num).toInt(),
      monthsPaid: (json['monthsPaid'] as num?)?.toInt() ?? 0,
      monthsPending: (json['monthsPending'] as num?)?.toInt() ?? 0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$MemberYearlySummaryImplToJson(
        _$MemberYearlySummaryImpl instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'fullName': instance.fullName,
      'memberNumber': instance.memberNumber,
      'year': instance.year,
      'monthsPaid': instance.monthsPaid,
      'monthsPending': instance.monthsPending,
      'totalPaid': instance.totalPaid,
    };
