// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'withdrawal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Withdrawal _$WithdrawalFromJson(Map<String, dynamic> json) {
  return _Withdrawal.fromJson(json);
}

/// @nodoc
mixin _$Withdrawal {
  String get id => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String get withdrawnBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  Profile? get withdrawnByProfile => throw _privateConstructorUsedError;

  /// Serializes this Withdrawal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Withdrawal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WithdrawalCopyWith<Withdrawal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WithdrawalCopyWith<$Res> {
  factory $WithdrawalCopyWith(
          Withdrawal value, $Res Function(Withdrawal) then) =
      _$WithdrawalCopyWithImpl<$Res, Withdrawal>;
  @useResult
  $Res call(
      {String id,
      double amount,
      String reason,
      String withdrawnBy,
      DateTime createdAt,
      Profile? withdrawnByProfile});

  $ProfileCopyWith<$Res>? get withdrawnByProfile;
}

/// @nodoc
class _$WithdrawalCopyWithImpl<$Res, $Val extends Withdrawal>
    implements $WithdrawalCopyWith<$Res> {
  _$WithdrawalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Withdrawal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? reason = null,
    Object? withdrawnBy = null,
    Object? createdAt = null,
    Object? withdrawnByProfile = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      withdrawnBy: null == withdrawnBy
          ? _value.withdrawnBy
          : withdrawnBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      withdrawnByProfile: freezed == withdrawnByProfile
          ? _value.withdrawnByProfile
          : withdrawnByProfile // ignore: cast_nullable_to_non_nullable
              as Profile?,
    ) as $Val);
  }

  /// Create a copy of Withdrawal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileCopyWith<$Res>? get withdrawnByProfile {
    if (_value.withdrawnByProfile == null) {
      return null;
    }

    return $ProfileCopyWith<$Res>(_value.withdrawnByProfile!, (value) {
      return _then(_value.copyWith(withdrawnByProfile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WithdrawalImplCopyWith<$Res>
    implements $WithdrawalCopyWith<$Res> {
  factory _$$WithdrawalImplCopyWith(
          _$WithdrawalImpl value, $Res Function(_$WithdrawalImpl) then) =
      __$$WithdrawalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      double amount,
      String reason,
      String withdrawnBy,
      DateTime createdAt,
      Profile? withdrawnByProfile});

  @override
  $ProfileCopyWith<$Res>? get withdrawnByProfile;
}

/// @nodoc
class __$$WithdrawalImplCopyWithImpl<$Res>
    extends _$WithdrawalCopyWithImpl<$Res, _$WithdrawalImpl>
    implements _$$WithdrawalImplCopyWith<$Res> {
  __$$WithdrawalImplCopyWithImpl(
      _$WithdrawalImpl _value, $Res Function(_$WithdrawalImpl) _then)
      : super(_value, _then);

  /// Create a copy of Withdrawal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? reason = null,
    Object? withdrawnBy = null,
    Object? createdAt = null,
    Object? withdrawnByProfile = freezed,
  }) {
    return _then(_$WithdrawalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      withdrawnBy: null == withdrawnBy
          ? _value.withdrawnBy
          : withdrawnBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      withdrawnByProfile: freezed == withdrawnByProfile
          ? _value.withdrawnByProfile
          : withdrawnByProfile // ignore: cast_nullable_to_non_nullable
              as Profile?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WithdrawalImpl implements _Withdrawal {
  const _$WithdrawalImpl(
      {required this.id,
      required this.amount,
      required this.reason,
      required this.withdrawnBy,
      required this.createdAt,
      this.withdrawnByProfile});

  factory _$WithdrawalImpl.fromJson(Map<String, dynamic> json) =>
      _$$WithdrawalImplFromJson(json);

  @override
  final String id;
  @override
  final double amount;
  @override
  final String reason;
  @override
  final String withdrawnBy;
  @override
  final DateTime createdAt;
  @override
  final Profile? withdrawnByProfile;

  @override
  String toString() {
    return 'Withdrawal(id: $id, amount: $amount, reason: $reason, withdrawnBy: $withdrawnBy, createdAt: $createdAt, withdrawnByProfile: $withdrawnByProfile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WithdrawalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.withdrawnBy, withdrawnBy) ||
                other.withdrawnBy == withdrawnBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.withdrawnByProfile, withdrawnByProfile) ||
                other.withdrawnByProfile == withdrawnByProfile));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, amount, reason, withdrawnBy,
      createdAt, withdrawnByProfile);

  /// Create a copy of Withdrawal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WithdrawalImplCopyWith<_$WithdrawalImpl> get copyWith =>
      __$$WithdrawalImplCopyWithImpl<_$WithdrawalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WithdrawalImplToJson(
      this,
    );
  }
}

abstract class _Withdrawal implements Withdrawal {
  const factory _Withdrawal(
      {required final String id,
      required final double amount,
      required final String reason,
      required final String withdrawnBy,
      required final DateTime createdAt,
      final Profile? withdrawnByProfile}) = _$WithdrawalImpl;

  factory _Withdrawal.fromJson(Map<String, dynamic> json) =
      _$WithdrawalImpl.fromJson;

  @override
  String get id;
  @override
  double get amount;
  @override
  String get reason;
  @override
  String get withdrawnBy;
  @override
  DateTime get createdAt;
  @override
  Profile? get withdrawnByProfile;

  /// Create a copy of Withdrawal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WithdrawalImplCopyWith<_$WithdrawalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
