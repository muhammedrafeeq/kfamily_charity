import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toMonthYear() => DateFormat('MMMM yyyy').format(this);
  String toShortMonth() => DateFormat('MMM yyyy').format(this);
  String toDisplayDate() => DateFormat('dd MMM yyyy').format(this);
  String toDisplayDateTime() => DateFormat('dd MMM yyyy, hh:mm a').format(this);
  bool isSameMonth(DateTime other) => year == other.year && month == other.month;

  bool get isWithinPaymentWindow {
    final now = DateTime.now();
    return isSameMonth(now) && now.day >= 1 && now.day <= 10;
  }
}
