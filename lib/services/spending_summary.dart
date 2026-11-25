
import 'dart:math' as math;

import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/models/transaction_entry.dart';

enum SummaryPeriod {
  weekly('Weekly'),
  monthly('Monthly');

  const SummaryPeriod(this.label);

  final String label;
}

class TopCategory {
  const TopCategory({
    required this.category,
    required this.amount,
    required this.share,
  });

  final TransactionCategory category;
  final double amount;
  final double share;
}

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

  factory SpendingSummary.fromTransactions(
    List<TransactionEntry> transactions, {
    required SummaryPeriod period,
    required DateTime today,
    double? budgetLimit,
  }) {
    final isWeekly = period == SummaryPeriod.weekly;

    final weekStart = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );

    final weekEnd = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 7,
    );

    final daysInMonth = DateTime(
      today.year,
      today.month + 1,
      0,
    ).day;

    final barCount = isWeekly ? 7 : (daysInMonth + 6) ~/ 7;

    final barValues = List<double>.filled(barCount, 0);
    final categoryTotals = <TransactionCategory, double>{};

    var totalSpent = 0.0;

    for (final transaction in transactions) {
      if (!transaction.isExpense) continue;

      final date = transaction.dateTime;
      final int barIndex;

      if (isWeekly) {
        if (date.isBefore(weekStart) || !date.isBefore(weekEnd)) {
          continue;
        }

        barIndex = date.weekday - 1;
      } else {
        if (date.year != today.year || date.month != today.month) {
          continue;
        }

        barIndex = (date.day - 1) ~/ 7;
      }

      barValues[barIndex] += transaction.amount;
      totalSpent += transaction.amount;

      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) +
              transaction.amount;
    }

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
          : [
              for (var i = 1; i <= barCount; i++) 'Week $i',
            ],
      barValues: barValues,
      axisMax: niceAxisMax(
        barValues.fold<double>(0, math.max),
      ),
      totalSpent: totalSpent,
      budgetLimit: budgetLimit ??
          (isWeekly ? weeklyBudgetLimit : monthlyBudgetLimit),
      topCategory: top,
    );
  }

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
  final List<String> barLabels;
  final List<double> barValues;
  final double axisMax;
  final double totalSpent;
  final double budgetLimit;
  final TopCategory? topCategory;
}

double niceAxisMax(double maxValue) {
  if (maxValue <= 0) return 1000;

  var magnitude = 1.0;

  while (true) {
    for (final multiplier in const [1, 2, 5]) {
      final step = magnitude * multiplier;

      if (step * 5 >= maxValue) {
        return step * 5;
      }
    }

    magnitude *= 10;
  }
}
