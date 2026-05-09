// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_contribution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PaymentContribution _$PaymentContributionFromJson(Map<String, dynamic> json) {
  return _PaymentContribution.fromJson(json);
}

/// @nodoc
mixin _$PaymentContribution {
  String get id => throw _privateConstructorUsedError;
  String get cycleId => throw _privateConstructorUsedError;
  String get memberId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get screenshotUrl => throw _privateConstructorUsedError;
  String? get screenshotPath => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  String? get reviewedBy => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  Profile? get member => throw _privateConstructorUsedError;
  PaymentCycle? get cycle => throw _privateConstructorUsedError;

  /// Serializes this PaymentContribution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentContribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentContributionCopyWith<PaymentContribution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentContributionCopyWith<$Res> {
  factory $PaymentContributionCopyWith(
          PaymentContribution value, $Res Function(PaymentContribution) then) =
      _$PaymentContributionCopyWithImpl<$Res, PaymentContribution>;
  @useResult
  $Res call(
      {String id,
      String cycleId,
      String memberId,
      double amount,
      String status,
      String? screenshotUrl,
      String? screenshotPath,
      DateTime? submittedAt,
      DateTime? reviewedAt,
      String? reviewedBy,
      String? rejectionReason,
      String? notes,
      DateTime createdAt,
      Profile? member,
      PaymentCycle? cycle});

  $ProfileCopyWith<$Res>? get member;
  $PaymentCycleCopyWith<$Res>? get cycle;
}

/// @nodoc
class _$PaymentContributionCopyWithImpl<$Res, $Val extends PaymentContribution>
    implements $PaymentContributionCopyWith<$Res> {
  _$PaymentContributionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentContribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cycleId = null,
    Object? memberId = null,
    Object? amount = null,
    Object? status = null,
    Object? screenshotUrl = freezed,
    Object? screenshotPath = freezed,
    Object? submittedAt = freezed,
    Object? reviewedAt = freezed,
    Object? reviewedBy = freezed,
    Object? rejectionReason = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? member = freezed,
    Object? cycle = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      cycleId: null == cycleId
          ? _value.cycleId
          : cycleId // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      screenshotUrl: freezed == screenshotUrl
          ? _value.screenshotUrl
          : screenshotUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      screenshotPath: freezed == screenshotPath
          ? _value.screenshotPath
          : screenshotPath // ignore: cast_nullable_to_non_nullable
              as String?,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      member: freezed == member
          ? _value.member
          : member // ignore: cast_nullable_to_non_nullable
              as Profile?,
      cycle: freezed == cycle
          ? _value.cycle
          : cycle // ignore: cast_nullable_to_non_nullable
              as PaymentCycle?,
    ) as $Val);
  }

  /// Create a copy of PaymentContribution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileCopyWith<$Res>? get member {
    if (_value.member == null) {
      return null;
    }

    return $ProfileCopyWith<$Res>(_value.member!, (value) {
      return _then(_value.copyWith(member: value) as $Val);
    });
  }

  /// Create a copy of PaymentContribution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaymentCycleCopyWith<$Res>? get cycle {
    if (_value.cycle == null) {
      return null;
    }

    return $PaymentCycleCopyWith<$Res>(_value.cycle!, (value) {
      return _then(_value.copyWith(cycle: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PaymentContributionImplCopyWith<$Res>
    implements $PaymentContributionCopyWith<$Res> {
  factory _$$PaymentContributionImplCopyWith(_$PaymentContributionImpl value,
          $Res Function(_$PaymentContributionImpl) then) =
      __$$PaymentContributionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String cycleId,
      String memberId,
      double amount,
      String status,
      String? screenshotUrl,
      String? screenshotPath,
      DateTime? submittedAt,
      DateTime? reviewedAt,
      String? reviewedBy,
      String? rejectionReason,
      String? notes,
      DateTime createdAt,
      Profile? member,
      PaymentCycle? cycle});

  @override
  $ProfileCopyWith<$Res>? get member;
  @override
  $PaymentCycleCopyWith<$Res>? get cycle;
}

/// @nodoc
class __$$PaymentContributionImplCopyWithImpl<$Res>
    extends _$PaymentContributionCopyWithImpl<$Res, _$PaymentContributionImpl>
    implements _$$PaymentContributionImplCopyWith<$Res> {
  __$$PaymentContributionImplCopyWithImpl(_$PaymentContributionImpl _value,
      $Res Function(_$PaymentContributionImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentContribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? cycleId = null,
    Object? memberId = null,
    Object? amount = null,
    Object? status = null,
    Object? screenshotUrl = freezed,
    Object? screenshotPath = freezed,
    Object? submittedAt = freezed,
    Object? reviewedAt = freezed,
    Object? reviewedBy = freezed,
    Object? rejectionReason = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? member = freezed,
    Object? cycle = freezed,
  }) {
    return _then(_$PaymentContributionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      cycleId: null == cycleId
          ? _value.cycleId
          : cycleId // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      screenshotUrl: freezed == screenshotUrl
          ? _value.screenshotUrl
          : screenshotUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      screenshotPath: freezed == screenshotPath
          ? _value.screenshotPath
          : screenshotPath // ignore: cast_nullable_to_non_nullable
              as String?,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      member: freezed == member
          ? _value.member
          : member // ignore: cast_nullable_to_non_nullable
              as Profile?,
      cycle: freezed == cycle
          ? _value.cycle
          : cycle // ignore: cast_nullable_to_non_nullable
              as PaymentCycle?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentContributionImpl extends _PaymentContribution {
  const _$PaymentContributionImpl(
      {required this.id,
      required this.cycleId,
      required this.memberId,
      this.amount = 0.0,
      this.status = 'pending',
      this.screenshotUrl,
      this.screenshotPath,
      this.submittedAt,
      this.reviewedAt,
      this.reviewedBy,
      this.rejectionReason,
      this.notes,
      required this.createdAt,
      this.member,
      this.cycle})
      : super._();

  factory _$PaymentContributionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentContributionImplFromJson(json);

  @override
  final String id;
  @override
  final String cycleId;
  @override
  final String memberId;
  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey()
  final String status;
  @override
  final String? screenshotUrl;
  @override
  final String? screenshotPath;
  @override
  final DateTime? submittedAt;
  @override
  final DateTime? reviewedAt;
  @override
  final String? reviewedBy;
  @override
  final String? rejectionReason;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final Profile? member;
  @override
  final PaymentCycle? cycle;

  @override
  String toString() {
    return 'PaymentContribution(id: $id, cycleId: $cycleId, memberId: $memberId, amount: $amount, status: $status, screenshotUrl: $screenshotUrl, screenshotPath: $screenshotPath, submittedAt: $submittedAt, reviewedAt: $reviewedAt, reviewedBy: $reviewedBy, rejectionReason: $rejectionReason, notes: $notes, createdAt: $createdAt, member: $member, cycle: $cycle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentContributionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.cycleId, cycleId) || other.cycleId == cycleId) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.screenshotUrl, screenshotUrl) ||
                other.screenshotUrl == screenshotUrl) &&
            (identical(other.screenshotPath, screenshotPath) ||
                other.screenshotPath == screenshotPath) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.member, member) || other.member == member) &&
            (identical(other.cycle, cycle) || other.cycle == cycle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      cycleId,
      memberId,
      amount,
      status,
      screenshotUrl,
      screenshotPath,
      submittedAt,
      reviewedAt,
      reviewedBy,
      rejectionReason,
      notes,
      createdAt,
      member,
      cycle);

  /// Create a copy of PaymentContribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentContributionImplCopyWith<_$PaymentContributionImpl> get copyWith =>
      __$$PaymentContributionImplCopyWithImpl<_$PaymentContributionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentContributionImplToJson(
      this,
    );
  }
}

abstract class _PaymentContribution extends PaymentContribution {
  const factory _PaymentContribution(
      {required final String id,
      required final String cycleId,
      required final String memberId,
      final double amount,
      final String status,
      final String? screenshotUrl,
      final String? screenshotPath,
      final DateTime? submittedAt,
      final DateTime? reviewedAt,
      final String? reviewedBy,
      final String? rejectionReason,
      final String? notes,
      required final DateTime createdAt,
      final Profile? member,
      final PaymentCycle? cycle}) = _$PaymentContributionImpl;
  const _PaymentContribution._() : super._();

  factory _PaymentContribution.fromJson(Map<String, dynamic> json) =
      _$PaymentContributionImpl.fromJson;

  @override
  String get id;
  @override
  String get cycleId;
  @override
  String get memberId;
  @override
  double get amount;
  @override
  String get status;
  @override
  String? get screenshotUrl;
  @override
  String? get screenshotPath;
  @override
  DateTime? get submittedAt;
  @override
  DateTime? get reviewedAt;
  @override
  String? get reviewedBy;
  @override
  String? get rejectionReason;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  Profile? get member;
  @override
  PaymentCycle? get cycle;

  /// Create a copy of PaymentContribution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentContributionImplCopyWith<_$PaymentContributionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
