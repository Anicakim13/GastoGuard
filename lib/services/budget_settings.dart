import 'package:gastoguard/utils/currency_formatter.dart';

/// One budget alert, for example "notify me at 80% of my budget".
class BudgetAlertLevel {
  const BudgetAlertLevel(this.percent);

  /// How much of the budget has been used when the alert goes off (80 = 80%).
  final int percent;

  /// The amount of money at which this alert goes off, for a budget [limit].
  double amountFor(double limit) => limit * percent / 100;

  /// The text shown next to the switch, for example "Notify at 80% (₱800.00)".
  String labelFor(double limit) {
    return 'Notify at $percent% (${formatPeso(amountFor(limit))})';
  }
}

/// The alerts shown on the Budget Settings screen, in order.
const List<BudgetAlertLevel> budgetAlertLevels = [
  BudgetAlertLevel(80),
  BudgetAlertLevel(100),
];

/// A budget as shown in the amount field when it is not being edited, without
/// the peso sign (the field draws that itself): 4000 -> "4,000.00".
String formatBudgetField(double amount) {
  return formatPeso(amount).replaceFirst('₱', '');
}

/// A budget as shown while it is being edited, without commas: "4000.00".
String editableBudgetText(double amount) => amount.toStringAsFixed(2);
