import 'package:intl/intl.dart';

class Formatter {
  // Formatează un preț în formatul local
  static String formatPrice(double price) {
    final format = NumberFormat.currency(symbol: 'RON', decimalDigits: 2);
    return format.format(price);
  }
}
