import 'package:intl/intl.dart';
import 'package:project_mopro/data/mock_rentals.dart';

class ReportService {
  /// Total income for given date (day)
  static int incomeForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    int sum = 0;
    for (final r in MockRentals.records) {
      final d = r['date'] as DateTime;
      if (!d.isBefore(start) && d.isBefore(end)) {
        sum += r['price'] as int;
      }
    }
    return sum;
  }

  /// Total income for given month
  static int incomeForMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    int sum = 0;
    for (final r in MockRentals.records) {
      final d = r['date'] as DateTime;
      if (!d.isBefore(start) && d.isBefore(end)) {
        sum += r['price'] as int;
      }
    }
    return sum;
  }

  /// Returns map of costume title -> count rented
  static Map<String, int> topCostumes({int limit = 5}) {
    final counts = <String, int>{};
    for (final r in MockRentals.records) {
      final title = r['title'] as String;
      counts[title] = (counts[title] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final result = <String, int>{};
    for (var i = 0; i < sorted.length && i < limit; i++) {
      result[sorted[i].key] = sorted[i].value;
    }
    return result;
  }

  static String formatCurrency(int value) {
    final f = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return f.format(value);
  }
}
