// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_cycle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PaymentCycle _$PaymentCycleFromJson(Map<String, dynamic> json) {
  return _PaymentCycle.fromJson(json);
}

/// @nodoc
mixin _$PaymentCycle {
  String get id => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get closedAt => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// Serializes this PaymentCycle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentCycle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentCycleCopyWith<PaymentCycle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentCycleCopyWith<$Res> {
  factory $PaymentCycleCopyWith(
          PaymentCycle value, $Res Function(PaymentCycle) then) =
      _$PaymentCycleCopyWithImpl<$Res, PaymentCycle>;
  @useResult
  $Res call(
      {String id,
      int year,
      int month,
      String status,
      String? createdBy,
      DateTime createdAt,
      DateTime? closedAt,
      DateTime? endDate});
}

/// @nodoc
class _$PaymentCycleCopyWithImpl<$Res, $Val extends PaymentCycle>
    implements $PaymentCycleCopyWith<$Res> {
  _$PaymentCycleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentCycle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? year = null,
    Object? month = null,
    Object? status = null,
    Object? createdBy = freezed,
    Object? createdAt = null,
    Object? closedAt = freezed,
    Object? endDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentCycleImplCopyWith<$Res>
    implements $PaymentCycleCopyWith<$Res> {
  factory _$$PaymentCycleImplCopyWith(
          _$PaymentCycleImpl value, $Res Function(_$PaymentCycleImpl) then) =
      __$$PaymentCycleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int year,
      int month,
      String status,
      String? createdBy,
      DateTime createdAt,
      DateTime? closedAt,
      DateTime? endDate});
}

/// @nodoc
class __$$PaymentCycleImplCopyWithImpl<$Res>
    extends _$PaymentCycleCopyWithImpl<$Res, _$PaymentCycleImpl>
    implements _$$PaymentCycleImplCopyWith<$Res> {
  __$$PaymentCycleImplCopyWithImpl(
      _$PaymentCycleImpl _value, $Res Function(_$PaymentCycleImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentCycle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? year = null,
    Object? month = null,
    Object? status = null,
    Object? createdBy = freezed,
    Object? createdAt = null,
    Object? closedAt = freezed,
    Object? endDate = freezed,
  }) {
    return _then(_$PaymentCycleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentCycleImpl extends _PaymentCycle {
  const _$PaymentCycleImpl(
      {required this.id,
      required this.year,
      required this.month,
      required this.status,
      this.createdBy,
      required this.createdAt,
      this.closedAt,
      this.endDate})
      : super._();

  factory _$PaymentCycleImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentCycleImplFromJson(json);

  @override
  final String id;
  @override
  final int year;
  @override
  final int month;
  @override
  final String status;
  @override
  final String? createdBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime? closedAt;
  @override
  final DateTime? endDate;

  @override
  String toString() {
    return 'PaymentCycle(id: $id, year: $year, month: $month, status: $status, createdBy: $createdBy, createdAt: $createdAt, closedAt: $closedAt, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentCycleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, year, month, status,
      createdBy, createdAt, closedAt, endDate);

  /// Create a copy of PaymentCycle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentCycleImplCopyWith<_$PaymentCycleImpl> get copyWith =>
      __$$PaymentCycleImplCopyWithImpl<_$PaymentCycleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentCycleImplToJson(
      this,
    );
  }
}

abstract class _PaymentCycle extends PaymentCycle {
  const factory _PaymentCycle(
      {required final String id,
      required final int year,
      required final int month,
      required final String status,
      final String? createdBy,
      required final DateTime createdAt,
      final DateTime? closedAt,
      final DateTime? endDate}) = _$PaymentCycleImpl;
  const _PaymentCycle._() : super._();

  factory _PaymentCycle.fromJson(Map<String, dynamic> json) =
      _$PaymentCycleImpl.fromJson;

  @override
  String get id;
  @override
  int get year;
  @override
  int get month;
  @override
  String get status;
  @override
  String? get createdBy;
  @override
  DateTime get createdAt;
  @override
  DateTime? get closedAt;
  @override
  DateTime? get endDate;

  /// Create a copy of PaymentCycle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentCycleImplCopyWith<_$PaymentCycleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
