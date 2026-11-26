
import 'package:gastoguard/models/transaction_entry.dart';


class BudgetAlert {
  const BudgetAlert({
    required this.percent,
    required this.spent,
    required this.limit,
  });

  final int percent;
  final double spent;
  final double limit;

  double get remaining => (limit - spent).clamp(0.0, double.infinity);

  double get overspent => (spent - limit).clamp(0.0, double.infinity);
}

class BudgetAlertService {
  const BudgetAlertService();

  List<BudgetAlert> checkThresholds({
    required List<TransactionEntry> previousTransactions,
    required List<TransactionEntry> currentTransactions,
    required DateTime today,
    required double weeklyLimit,
    required bool alert80Enabled,
    required bool alert100Enabled,
  }) {
    if (weeklyLimit <= 0) return [];

    final previousSpent = _weeklyExpenseTotal(
      previousTransactions,
      today,
    );

    final currentSpent = _weeklyExpenseTotal(
      currentTransactions,
      today,
    );

    final thresholds = [
      (percent: 80, enabled: alert80Enabled),
      (percent: 100, enabled: alert100Enabled),
    ];

    return thresholds
        .where((threshold) {
          if (!threshold.enabled) return false;

          final amount = weeklyLimit * threshold.percent / 100;

          return previousSpent < amount && currentSpent >= amount;
        })
        .map(
          (threshold) => BudgetAlert(
            percent: threshold.percent,
            spent: currentSpent,
            limit: weeklyLimit,
          ),
        )
        .toList();
  }

  double _weeklyExpenseTotal(
    List<TransactionEntry> transactions,
    DateTime today,
  ) {
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

    return transactions
        .where((transaction) {
          return transaction.isExpense &&
              !transaction.dateTime.isBefore(weekStart) &&
              transaction.dateTime.isBefore(weekEnd);
        })
        .fold<double>(
          0,
          (total, transaction) => total + transaction.amount,
        );
  }
}
