// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_cycle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentCycleImpl _$$PaymentCycleImplFromJson(Map<String, dynamic> json) =>
    _$PaymentCycleImpl(
      id: json['id'] as String,
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      status: json['status'] as String,
      createdBy: json['createdBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
    );

Map<String, dynamic> _$$PaymentCycleImplToJson(_$PaymentCycleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'year': instance.year,
      'month': instance.month,
      'status': instance.status,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'closedAt': instance.closedAt?.toIso8601String(),
    };
