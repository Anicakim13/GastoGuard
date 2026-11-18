import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/services/demo_transactions.dart';
import 'package:gastoguard/services/transaction_filter.dart';

void main() {
  // Demo data for November 2026: 5 + 5 + 3 + 1 = 14 transactions.
  final today = DateTime(2026, 11, 15);
  final all = buildDemoTransactions(today);

  test('demo data has 14 transactions spread over four months', () {
    expect(all.length, 14);
    final ids = all.map((transaction) => transaction.id).toSet();
    expect(ids.length, 14); // every id is unique
  });

  test('the period filter picks the right months', () {
    int count(HistoryPeriod period) =>
        filterTransactions(all, today: today, period: period).length;

    expect(count(HistoryPeriod.thisMonth), 5);
    expect(count(HistoryPeriod.lastMonth), 5);
    expect(count(HistoryPeriod.last3Months), 13);
    expect(count(HistoryPeriod.allTime), 14);
  });

  test('the type filter separates income from expenses', () {
    final income = filterTransactions(
      all,
      today: today,
      type: TypeFilter.income,
      period: HistoryPeriod.allTime,
    );
    final expenses = filterTransactions(
      all,
      today: today,
      type: TypeFilter.expense,
      period: HistoryPeriod.allTime,
    );
    expect(income.length, 3);
    expect(income.every((transaction) => !transaction.isExpense), isTrue);
    expect(expenses.length, 11);
    expect(expenses.every((transaction) => transaction.isExpense), isTrue);
  });

  test('the category filter keeps only that category', () {
    final food = filterTransactions(
      all,
      today: today,
      category: TransactionCategory.food,
    );
    expect(food.length, 3);
    expect(
      food.every((transaction) => transaction.category == TransactionCategory.food),
      isTrue,
    );
  });

  test('search ignores upper/lower case and needs every word to match', () {
    int count(String query) => filterTransactions(
          all,
          today: today,
          query: query,
        ).length;

    expect(count('TRANSPORTATION'), 2);
    expect(count('  transportation  '), 2);
    expect(count('transportation october'), 1);
    expect(count('150'), 2); // ₱150.00: Food and Entertainment
    expect(count('no such thing'), 0);
    expect(count(''), 14);
  });

  test('groupByMonth lists months newest first, oldest transaction first', () {
    final groups = groupByMonth(all);

    expect(groups.map((group) => group.month).toList(), [
      DateTime(2026, 11),
      DateTime(2026, 10),
      DateTime(2026, 9),
      DateTime(2026, 8),
    ]);
    expect(groups.map((group) => group.transactions.length).toList(),
        [5, 5, 3, 1]);

    final november = groups.first.transactions;
    expect(november.first.dateTime.day, 1);
    expect(november.last.dateTime.day, 28);
  });

  test('groupByMonth handles a year change', () {
    final january = DateTime(2026, 1, 20);
    final groups = groupByMonth(buildDemoTransactions(january));

    expect(groups.map((group) => group.month).toList(), [
      DateTime(2026, 1),
      DateTime(2025, 12),
      DateTime(2025, 11),
      DateTime(2025, 10),
    ]);
  });
}
