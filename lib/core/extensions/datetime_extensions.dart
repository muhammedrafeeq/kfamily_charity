import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toMonthYear() => DateFormat('MMMM yyyy').format(toLocal());
  String toShortMonth() => DateFormat('MMM yyyy').format(toLocal());
  String toDisplayDate() => DateFormat('dd MMM yyyy').format(toLocal());
  String toDisplayDateTime() => DateFormat('dd MMM yyyy, hh:mm a').format(toLocal());
  bool isSameMonth(DateTime other) => year == other.year && month == other.month;

  bool get isWithinPaymentWindow {
    final now = DateTime.now();
    return isSameMonth(now) && now.day >= 1 && now.day <= 10;
  }
}
