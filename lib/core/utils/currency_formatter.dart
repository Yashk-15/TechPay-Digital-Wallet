import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String symbol = '₹'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
      locale: 'en_IN',
    );
    return formatter.format(amount);
  }
}
