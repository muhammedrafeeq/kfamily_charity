import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import '../core/utils/json_utils.dart';

part 'payment_cycle.freezed.dart';
part 'payment_cycle.g.dart';

@freezed
class PaymentCycle with _$PaymentCycle {
  const PaymentCycle._();

  const factory PaymentCycle({
    required String id,
    required int year,
    required int month,
    required String status,
    String? createdBy,
    required DateTime createdAt,
    DateTime? closedAt,
  }) = _PaymentCycle;

  factory PaymentCycle.fromJson(Map<String, dynamic> json) =>
      _$PaymentCycleFromJson(snakeToCamel(json));

  String get displayName => DateFormat('MMMM yyyy').format(DateTime(year, month));
  bool get isOpen => status == 'open';

  bool get isWithinPaymentWindow {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day >= 1 && now.day <= 10;
  }
}
