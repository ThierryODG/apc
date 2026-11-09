import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat('#,###', 'fr_FR');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');
  static final DateFormat _shortDate = DateFormat('dd/MM/yyyy', 'fr_FR');

  static String formatCurrency(num amount, {String suffix = 'F'}) {
    final formatted = _currencyFormat.format(amount).replaceAll(',', ' ');
    return '$formatted $suffix';
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return _dateFormat.format(dateTime);
  }

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return _shortDate.format(dateTime);
  }
}

