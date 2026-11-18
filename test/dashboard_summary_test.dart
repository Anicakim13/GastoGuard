import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/models/category_spending.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/models/transaction_entry.dart';
import 'package:gastoguard/services/dashboard_summary.dart';
import 'package:gastoguard/services/demo_transactions.dart';

void main() {
  // A quick way to make a transaction for these tests.
  TransactionEntry entry(
    TransactionCategory category,
    double amount, {
    bool isExpense = true,
  }) {
    return TransactionEntry(
      id: 'test',
      category: category,
      amount: amount,
      isExpense: isExpense,
      dateTime: DateTime(2026, 11, 9, 12, 0),
    );
  }

  List<String> names(List<CategorySpending> items) =>
      items.map((item) => item.name).toList();
  List<double> percents(List<CategorySpending> items) =>
      items.map((item) => item.percent).toList();

  test('the sample matches the numbers in the Canva design', () {
    const sample = DashboardSummary.sample;

    expect(sample.totalIncome, 1000);
    expect(sample.totalExpenses, 150);
    expect(sample.balance, 850);
    expect(sample.balanceShare, closeTo(0.85, 0.0001));
    expect(names(sample.legendItems), ['Food', 'Transport', 'Data', 'Others']);
    expect(percents(sample.legendItems), [40, 30, 20, 10]);
    // The pie draws its slices in a different order, like the design.
    expect(names(sample.pieSlices), ['Transport', 'Data', 'Food', 'Others']);
  });

  test('with no transactions everything is zero', () {
    final summary = DashboardSummary.fromTransactions([]);

    expect(summary.totalIncome, 0);
    expect(summary.totalExpenses, 0);
    expect(summary.balance, 0);
    expect(summary.balanceShare, 0);
    expect(percents(summary.legendItems), [0, 0, 0, 0]);
  });

  test('income, expenses, and balance are added up', () {
    final summary = DashboardSummary.fromTransactions([
      entry(TransactionCategory.others, 1000, isExpense: false),
      entry(TransactionCategory.others, 500, isExpense: false),
      entry(TransactionCategory.food, 150),
      entry(TransactionCategory.transportation, 50),
    ]);

    expect(summary.totalIncome, 1500);
    expect(summary.totalExpenses, 200);
    expect(summary.balance, 1300);
    expect(summary.balanceShare, closeTo(1300 / 1500, 0.0001));
  });

  test('School Supplies and Entertainment are counted in "Others"', () {
    final summary = DashboardSummary.fromTransactions([
      entry(TransactionCategory.food, 100),
      entry(TransactionCategory.data, 100),
      entry(TransactionCategory.schoolSupplies, 100),
      entry(TransactionCategory.entertainment, 100),
    ]);

    expect(summary.food.percent, closeTo(25, 0.0001));
    expect(summary.transport.percent, 0);
    expect(summary.data.percent, closeTo(25, 0.0001));
    expect(summary.others.percent, closeTo(50, 0.0001));
  });

  test('an expense in the Others category counts in "Others"', () {
    final summary = DashboardSummary.fromTransactions([
      entry(TransactionCategory.others, 80),
    ]);
    expect(summary.others.percent, closeTo(100, 0.0001));
  });

  test('income is not part of the spending pie', () {
    final summary = DashboardSummary.fromTransactions([
      entry(TransactionCategory.food, 1000, isExpense: false),
    ]);

    expect(summary.totalExpenses, 0);
    expect(percents(summary.legendItems), [0, 0, 0, 0]);
    expect(summary.balance, 1000);
    expect(summary.balanceShare, 1);
  });

  test('spending more than the income gives a negative balance', () {
    final summary = DashboardSummary.fromTransactions([
      entry(TransactionCategory.others, 100, isExpense: false),
      entry(TransactionCategory.food, 300),
    ]);

    expect(summary.balance, -200);
    expect(summary.balanceShare, 0); // the bar is empty, never below zero
  });

  test('the pie shares add up to 100 when something was spent', () {
    final summary = DashboardSummary.fromTransactions(
      buildDemoTransactions(DateTime(2026, 11, 15)),
    );

    final total = summary.legendItems.fold<double>(
      0,
      (sum, item) => sum + item.percent,
    );
    expect(total, closeTo(100, 0.0001));
  });

  test('the sample transactions give the expected totals and shares', () {
    // 14 sample transactions: income 3,000; expenses 1,465
    // (Food 355, Transport 90, Data 160, School 510, Entertainment 350).
    final summary = DashboardSummary.fromTransactions(
      buildDemoTransactions(DateTime(2026, 11, 15)),
    );

    expect(summary.totalIncome, 3000);
    expect(summary.totalExpenses, 1465);
    expect(summary.balance, 1535);
    expect(summary.food.percent, closeTo(355 / 1465 * 100, 0.0001));
    expect(summary.transport.percent, closeTo(90 / 1465 * 100, 0.0001));
    expect(summary.data.percent, closeTo(160 / 1465 * 100, 0.0001));
    expect(summary.others.percent, closeTo(860 / 1465 * 100, 0.0001));
  });
}
