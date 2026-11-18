import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/models/transaction_entry.dart';
import 'package:gastoguard/utils/currency_formatter.dart';
import 'package:gastoguard/utils/date_formatter.dart';

/// The All / Income / Expense chips.
enum TypeFilter {
  all('All'),
  income('Income'),
  expense('Expense');

  const TypeFilter(this.label);

  /// The text shown on the chip.
  final String label;
}

/// The choices in the month dropdown.
enum HistoryPeriod {
  thisMonth('This Month'),
  lastMonth('Last Month'),
  last3Months('Last 3 Months'),
  allTime('All Time');

  const HistoryPeriod(this.label);

  /// The text shown in the dropdown.
  final String label;
}

/// All transactions of one month, for example "August 2026".
class MonthGroup {
  const MonthGroup({required this.month, required this.transactions});

  /// The first day of the month this group is for.
  final DateTime month;

  final List<TransactionEntry> transactions;
}

/// Returns only the transactions that match everything the person chose.
///
/// [today] decides what "This Month" means. A transaction is kept when:
///  - it matches the type (All / Income / Expense),
///  - it matches the category (null means every category),
///  - it falls inside the period, and
///  - every word typed in [query] appears in what the row shows
///    (category name, date and time, or amount).
List<TransactionEntry> filterTransactions(
  List<TransactionEntry> transactions, {
  required DateTime today,
  String query = '',
  TypeFilter type = TypeFilter.all,
  TransactionCategory? category,
  HistoryPeriod period = HistoryPeriod.allTime,
}) {
  final words = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();

  return transactions.where((transaction) {
    if (type == TypeFilter.income && transaction.isExpense) return false;
    if (type == TypeFilter.expense && !transaction.isExpense) return false;
    if (category != null && transaction.category != category) return false;
    if (!_isInPeriod(transaction.dateTime, period, today)) return false;

    final rowText = _searchableText(transaction);
    return words.every(rowText.contains);
  }).toList();
}

/// Groups transactions by month.
///
/// Months are listed newest first. Inside a month the oldest transaction comes
/// first, like in the Canva design.
List<MonthGroup> groupByMonth(List<TransactionEntry> transactions) {
  final byMonth = <int, List<TransactionEntry>>{};
  for (final transaction in transactions) {
    final key = transaction.dateTime.year * 12 + (transaction.dateTime.month - 1);
    byMonth.putIfAbsent(key, () => []).add(transaction);
  }

  final keys = byMonth.keys.toList()..sort((a, b) => b.compareTo(a));

  final groups = <MonthGroup>[];
  for (final key in keys) {
    final items = byMonth[key]!
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    groups.add(
      MonthGroup(month: DateTime(key ~/ 12, key % 12 + 1), transactions: items),
    );
  }
  return groups;
}

/// The text a row shows, in lower case, used for searching.
String _searchableText(TransactionEntry transaction) {
  return '${transaction.category.name} '
          '${formatDateTime(transaction.dateTime)} '
          '${formatPeso(transaction.amount)}'
      .toLowerCase();
}

bool _isInPeriod(DateTime date, HistoryPeriod period, DateTime today) {
  // How many months before today's month the transaction happened.
  final monthsAgo = (today.year - date.year) * 12 + (today.month - date.month);
  return switch (period) {
    HistoryPeriod.thisMonth => monthsAgo == 0,
    HistoryPeriod.lastMonth => monthsAgo == 1,
    HistoryPeriod.last3Months => monthsAgo >= 0 && monthsAgo <= 2,
    HistoryPeriod.allTime => true,
  };
}
