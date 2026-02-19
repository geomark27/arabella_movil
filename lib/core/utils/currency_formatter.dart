import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(String? amount, {String symbol = '\$'}) {
    if (amount == null || amount.isEmpty) return '$symbol 0.00';
    final value = double.tryParse(amount) ?? 0.0;
    return '${symbol} ${NumberFormat('#,##0.00', 'en_US').format(value)}';
  }

  static String formatDouble(double amount, {String symbol = '\$'}) {
    return '$symbol ${NumberFormat('#,##0.00', 'en_US').format(amount)}';
  }

  /// Convierte "1500.0000" → 1500.0
  static double parseAmount(String? amount) {
    if (amount == null || amount.isEmpty) return 0.0;
    return double.tryParse(amount) ?? 0.0;
  }

  static String runwayLabel(double months) {
    if (months >= 12) {
      return '${months.toStringAsFixed(1)} meses';
    }
    final days = (months * 30).round();
    return '${months.toStringAsFixed(1)} meses (~$days días)';
  }
}
