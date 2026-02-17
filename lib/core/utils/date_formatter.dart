import 'package:intl/intl.dart';

class DateFormatter {
  static String display(DateTime date) {
    return DateFormat('MMM d, y • h:mm a').format(date);
  }
}
