// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WithdrawalImpl _$$WithdrawalImplFromJson(Map<String, dynamic> json) =>
    _$WithdrawalImpl(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String,
      withdrawnBy: json['withdrawnBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      withdrawnByProfile: json['withdrawnByProfile'] == null
          ? null
          : Profile.fromJson(
              json['withdrawnByProfile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$WithdrawalImplToJson(_$WithdrawalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'reason': instance.reason,
      'withdrawnBy': instance.withdrawnBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'withdrawnByProfile': instance.withdrawnByProfile,
    };
