import 'package:intl/intl.dart';

class DateFormatter {
  static String display(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date).toUpperCase();
  }

  static String displayDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date).toUpperCase();
  }
}
