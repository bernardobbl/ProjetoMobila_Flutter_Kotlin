import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final _dateShort = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _dateLong = DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR');
  static final _monthYear = DateFormat('MMMM yyyy', 'pt_BR');
  static final _monthShort = DateFormat('MMM', 'pt_BR');

  static String currency(double value) => _currency.format(value);

  static String dateShort(DateTime date) => _dateShort.format(date);

  static String dateLong(DateTime date) => _dateLong.format(date);

  static String monthYear(DateTime date) => _monthYear.format(date);

  static String monthShort(DateTime date) => _monthShort.format(date);
}
