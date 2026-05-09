// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlySummaryImpl _$$MonthlySummaryImplFromJson(Map<String, dynamic> json) =>
    _$MonthlySummaryImpl(
      cycleId: json['cycleId'] as String,
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      status: json['status'] as String,
      paidCount: (json['paidCount'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
      rejectedCount: (json['rejectedCount'] as num?)?.toInt() ?? 0,
      totalCollected: (json['totalCollected'] as num?)?.toDouble() ?? 0.0,
      totalMembers: (json['totalMembers'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MonthlySummaryImplToJson(
        _$MonthlySummaryImpl instance) =>
    <String, dynamic>{
      'cycleId': instance.cycleId,
      'year': instance.year,
      'month': instance.month,
      'status': instance.status,
      'paidCount': instance.paidCount,
      'pendingCount': instance.pendingCount,
      'rejectedCount': instance.rejectedCount,
      'totalCollected': instance.totalCollected,
      'totalMembers': instance.totalMembers,
    };
