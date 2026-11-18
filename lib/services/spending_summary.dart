import 'dart:math' as math;

import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/models/transaction_entry.dart';

/// The Weekly | Monthly tabs.
enum SummaryPeriod {
  weekly('Weekly'),
  monthly('Monthly');

  const SummaryPeriod(this.label);

  /// The text shown on the tab.
  final String label;
}

/// The category with the most spending in the period.
class TopCategory {
  const TopCategory({
    required this.category,
    required this.amount,
    required this.share,
  });

  final TransactionCategory category;

  /// How much was spent in this category.
  final double amount;

  /// Its part of all the spending, from 0.0 to 1.0 (0.4 means 40%).
  final double share;
}

/// Everything the Spending Summary screen shows, worked out from the
/// transactions. Only EXPENSES are counted; income is ignored.
///
///  - Weekly:  this week, Monday to Sunday, with one bar for each day.
///  - Monthly: this month, with one bar for each block of seven days
///             (Week 1 = days 1-7, Week 2 = days 8-14, and so on).
class SpendingSummary {
  const SpendingSummary({
    required this.period,
    required this.barLabels,
    required this.barValues,
    required this.axisMax,
    required this.totalSpent,
    required this.budgetLimit,
    required this.topCategory,
  });

  /// Works out the summary. [today] decides which week or month "this" is.
  factory SpendingSummary.fromTransactions(
    List<TransactionEntry> transactions, {
    required SummaryPeriod period,
    required DateTime today,
  }) {
    final isWeekly = period == SummaryPeriod.weekly;

    // This week runs from Monday 00:00 up to (not including) next Monday.
    final weekStart =
        DateTime(today.year, today.month, today.day - (today.weekday - 1));
    final weekEnd = DateTime(weekStart.year, weekStart.month, weekStart.day + 7);

    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    final barCount = isWeekly ? 7 : (daysInMonth + 6) ~/ 7;

    final barValues = List<double>.filled(barCount, 0);
    final categoryTotals = <TransactionCategory, double>{};
    var totalSpent = 0.0;

    for (final transaction in transactions) {
      if (!transaction.isExpense) continue; // income is not spending

      final date = transaction.dateTime;
      final int barIndex;
      if (isWeekly) {
        if (date.isBefore(weekStart) || !date.isBefore(weekEnd)) continue;
        barIndex = date.weekday - 1; // Monday = 0 ... Sunday = 6
      } else {
        if (date.year != today.year || date.month != today.month) continue;
        barIndex = (date.day - 1) ~/ 7; // days 1-7 = 0, 8-14 = 1, ...
      }

      barValues[barIndex] += transaction.amount;
      totalSpent += transaction.amount;
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    // The category with the most spending. Going through the list in its
    // fixed order means a tie always goes to the earlier category.
    TopCategory? top;
    for (final category in TransactionCategory.all) {
      final amount = categoryTotals[category] ?? 0;
      if (amount > 0 && (top == null || amount > top.amount)) {
        top = TopCategory(
          category: category,
          amount: amount,
          share: amount / totalSpent,
        );
      }
    }

    return SpendingSummary(
      period: period,
      barLabels: isWeekly
          ? _weekdayLabels
          : [for (var i = 1; i <= barCount; i++) 'Week $i'],
      barValues: barValues,
      axisMax: niceAxisMax(barValues.fold<double>(0, math.max)),
      totalSpent: totalSpent,
      budgetLimit: isWeekly ? weeklyBudgetLimit : monthlyBudgetLimit,
      topCategory: top,
    );
  }

  /// SAMPLE budget limits. There is no Budget Settings screen yet, so these
  /// are fixed values (the weekly one matches the Dashboard's weekly budget).
  static const double weeklyBudgetLimit = 1000;
  static const double monthlyBudgetLimit = 4000;

  static const List<String> _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  final SummaryPeriod period;

  /// The names under the bars, for example Mon, Tue, ...
  final List<String> barLabels;

  /// How much was spent in each bar (same length as [barLabels]).
  final List<double> barValues;

  /// The value at the top of the chart's vertical axis.
  final double axisMax;

  /// All the spending in the period.
  final double totalSpent;

  /// The budget limit shown next to the total (a sample value for now).
  final double budgetLimit;

  /// The category with the most spending, or null if nothing was spent.
  final TopCategory? topCategory;
}

/// Picks a tidy top value for the chart's vertical axis.
///
/// The axis has 5 steps, and each step is 1, 2, or 5 times a power of ten, so
/// the labels are round numbers: 900 gives 1000 (steps of 200), 210 gives 250
/// (steps of 50). With nothing to show it gives 1000, like the Canva design.
double niceAxisMax(double maxValue) {
  if (maxValue <= 0) return 1000;

  var magnitude = 1.0;
  while (true) {
    for (final multiplier in const [1, 2, 5]) {
      final step = magnitude * multiplier;
      if (step * 5 >= maxValue) return step * 5;
    }
    magnitude *= 10;
  }
}
