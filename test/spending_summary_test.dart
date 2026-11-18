import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/models/transaction_entry.dart';
import 'package:gastoguard/services/demo_transactions.dart';
import 'package:gastoguard/services/spending_summary.dart';
import 'package:gastoguard/utils/currency_formatter.dart';

void main() {
  // "Today" is Wednesday, November 18, 2026. So "this week" is Monday
  // November 16 to Sunday November 22, and "this month" is November 2026.
  final today = DateTime(2026, 11, 18);

  TransactionEntry transaction(
    DateTime when,
    TransactionCategory category,
    double amount, {
    bool isExpense = true,
  }) {
    return TransactionEntry(
      id: 'test',
      category: category,
      amount: amount,
      isExpense: isExpense,
      dateTime: when,
    );
  }

  SpendingSummary summarize(
    List<TransactionEntry> transactions,
    SummaryPeriod period, {
    DateTime? on,
  }) {
    return SpendingSummary.fromTransactions(
      transactions,
      period: period,
      today: on ?? today,
    );
  }

  group('formatWholeNumber', () {
    test('adds thousands separators to the chart\'s axis numbers', () {
      expect(formatWholeNumber(0), '0');
      expect(formatWholeNumber(250), '250');
      expect(formatWholeNumber(1000), '1,000');
      expect(formatWholeNumber(25000), '25,000');
      expect(formatWholeNumber(1234567), '1,234,567');
      expect(formatWholeNumber(199.6), '200'); // rounded to a whole number
    });
  });

  group('niceAxisMax', () {
    test('gives round numbers for the vertical axis', () {
      expect(niceAxisMax(900), 1000); // steps of 200, like the design
      expect(niceAxisMax(1000), 1000);
      expect(niceAxisMax(210), 250); // steps of 50
      expect(niceAxisMax(45), 50); // steps of 10
      expect(niceAxisMax(1001), 2500); // steps of 500
      expect(niceAxisMax(3000), 5000); // steps of 1000
    });

    test('uses 1000 when there is nothing to show', () {
      expect(niceAxisMax(0), 1000);
    });
  });

  group('SpendingSummary weekly', () {
    final transactions = [
      transaction(DateTime(2026, 11, 16), TransactionCategory.food, 100), // Mon
      transaction(DateTime(2026, 11, 18), TransactionCategory.data, 50), // Wed
      transaction(DateTime(2026, 11, 18), TransactionCategory.food, 20), // Wed
      transaction(DateTime(2026, 11, 22, 23, 59), TransactionCategory.others, 30), // Sun
      // Outside this week:
      transaction(DateTime(2026, 11, 15), TransactionCategory.food, 999), // last Sun
      transaction(DateTime(2026, 11, 23), TransactionCategory.food, 888), // next Mon
      // Income is never counted:
      transaction(
        DateTime(2026, 11, 17),
        TransactionCategory.others,
        500,
        isExpense: false,
      ),
    ];

    test('has one bar for each day, Monday to Sunday', () {
      final summary = summarize(transactions, SummaryPeriod.weekly);

      expect(summary.barLabels, ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
      expect(summary.barValues, [100, 0, 70, 0, 0, 0, 30]);
      expect(summary.axisMax, 100);
    });

    test('counts only this week\'s expenses in the total', () {
      final summary = summarize(transactions, SummaryPeriod.weekly);

      expect(summary.totalSpent, 200);
      expect(summary.budgetLimit, SpendingSummary.weeklyBudgetLimit);
    });

    test('finds the top category', () {
      final top = summarize(transactions, SummaryPeriod.weekly).topCategory!;

      expect(top.category, TransactionCategory.food);
      expect(top.amount, 120);
      expect(top.share, closeTo(0.6, 0.0001));
    });
  });

  group('SpendingSummary monthly', () {
    final transactions = [
      transaction(DateTime(2026, 11, 1), TransactionCategory.food, 10), // Week 1
      transaction(DateTime(2026, 11, 7), TransactionCategory.food, 20), // Week 1
      transaction(DateTime(2026, 11, 8), TransactionCategory.data, 30), // Week 2
      transaction(DateTime(2026, 11, 14), TransactionCategory.data, 40), // Week 2
      transaction(DateTime(2026, 11, 15), TransactionCategory.others, 60), // Week 3
      transaction(DateTime(2026, 11, 28), TransactionCategory.others, 5), // Week 4
      transaction(DateTime(2026, 11, 30), TransactionCategory.food, 100), // Week 5
      // Outside this month:
      transaction(DateTime(2026, 10, 31), TransactionCategory.food, 777),
      transaction(DateTime(2025, 11, 10), TransactionCategory.food, 555),
      // Income is never counted:
      transaction(
        DateTime(2026, 11, 3),
        TransactionCategory.others,
        500,
        isExpense: false,
      ),
    ];

    test('has one bar for each block of seven days', () {
      final summary = summarize(transactions, SummaryPeriod.monthly);

      expect(summary.barLabels, ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5']);
      expect(summary.barValues, [30, 70, 60, 5, 100]);
    });

    test('adds up this month\'s expenses only', () {
      final summary = summarize(transactions, SummaryPeriod.monthly);

      expect(summary.totalSpent, 265);
      expect(summary.budgetLimit, SpendingSummary.monthlyBudgetLimit);
    });

    test('finds the top category', () {
      final top = summarize(transactions, SummaryPeriod.monthly).topCategory!;

      expect(top.category, TransactionCategory.food); // 10 + 20 + 100
      expect(top.amount, 130);
      expect(top.share, closeTo(130 / 265, 0.0001));
    });

    test('has four bars in a 28-day month and five in a longer one', () {
      final february = summarize([], SummaryPeriod.monthly, on: DateTime(2027, 2, 10));
      final january = summarize([], SummaryPeriod.monthly, on: DateTime(2027, 1, 10));

      expect(february.barValues.length, 4);
      expect(january.barValues.length, 5);
    });
  });

  group('SpendingSummary special cases', () {
    test('a tie goes to the category that comes first in the list', () {
      final summary = summarize([
        transaction(DateTime(2026, 11, 2), TransactionCategory.data, 100),
        transaction(DateTime(2026, 11, 3), TransactionCategory.food, 100),
      ], SummaryPeriod.monthly);

      expect(summary.topCategory!.category, TransactionCategory.food);
      expect(summary.topCategory!.share, closeTo(0.5, 0.0001));
    });

    test('with only income there is no spending at all', () {
      final summary = summarize([
        transaction(
          DateTime(2026, 11, 2),
          TransactionCategory.food,
          1000,
          isExpense: false,
        ),
      ], SummaryPeriod.monthly);

      expect(summary.totalSpent, 0);
      expect(summary.topCategory, isNull);
      expect(summary.barValues, [0, 0, 0, 0, 0]);
      expect(summary.axisMax, 1000);
    });

    test('with no transactions everything is empty', () {
      for (final period in SummaryPeriod.values) {
        final summary = summarize([], period);

        expect(summary.totalSpent, 0);
        expect(summary.topCategory, isNull);
        expect(summary.barValues.every((value) => value == 0), isTrue);
        expect(summary.axisMax, 1000);
      }
    });
  });

  group('SpendingSummary with the sample transactions', () {
    // On Monday, November 16, 2026. The sample expenses this month are on the
    // 8th (Food 150), 13th (Transportation 50), 17th (School Supplies 210),
    // and 28th (Data 60).
    final monday = DateTime(2026, 11, 16);
    final demo = buildDemoTransactions(monday);

    test('monthly', () {
      final summary = summarize(demo, SummaryPeriod.monthly, on: monday);

      expect(summary.barValues, [0, 200, 210, 60, 0]);
      expect(summary.axisMax, 250);
      expect(summary.totalSpent, 470);
      final top = summary.topCategory!;
      expect(top.category, TransactionCategory.schoolSupplies);
      expect(top.amount, 210);
      expect(top.share, closeTo(210 / 470, 0.0001));
    });

    test('weekly', () {
      final summary = summarize(demo, SummaryPeriod.weekly, on: monday);

      // Only the 17th (a Tuesday) is in the week of November 16-22.
      expect(summary.barValues, [0, 210, 0, 0, 0, 0, 0]);
      expect(summary.totalSpent, 210);
      expect(summary.topCategory!.share, closeTo(1, 0.0001));
    });
  });
}
