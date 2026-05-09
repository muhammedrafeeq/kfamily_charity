import 'package:intl/intl.dart';

extension DoubleExtensions on double {
  String toCurrency({String symbol = '₹'}) {
    final formatter = NumberFormat.currency(symbol: '$symbol ', decimalDigits: 2);
    return formatter.format(this);
  }

  String toPercent({int decimals = 1}) => '${(this * 100).toStringAsFixed(decimals)}%';
}

extension NumExtensions on num {
  String toCurrency({String symbol = '₹'}) => toDouble().toCurrency(symbol: symbol);
}
