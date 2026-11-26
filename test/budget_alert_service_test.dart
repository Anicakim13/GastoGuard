
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/models/transaction_entry.dart';
import 'package:gastoguard/services/budget_alert_service.dart';

void main() {
  const service = BudgetAlertService();

  final today = DateTime(2026, 11, 25);

  TransactionEntry expense(double amount, DateTime date) {
    return TransactionEntry(
      id: 'test-${amount.toString()}-${date.toIso8601String()}',
      category: TransactionCategory.food,
      amount: amount,
      isExpense: true,
      dateTime: date,
    );
  }

  TransactionEntry income(double amount, DateTime date) {
    return TransactionEntry(
      id: 'income-${amount.toString()}',
      category: TransactionCategory.food,
      amount: amount,
      isExpense: false,
      dateTime: date,
    );
  }

  group('BudgetAlertService', () {
    test('triggers 80% alert when spending reaches 80%', () {
      final alerts = service.checkThresholds(
        previousTransactions: [expense(750, today)],
        currentTransactions: [expense(800, today)],
        today: today,
        weeklyLimit: 1000,
        alert80Enabled: true,
        alert100Enabled: true,
      );

      expect(alerts.length, 1);
      expect(alerts.first.percent, 80);
      expect(alerts.first.remaining, 200);
    });

    test('triggers 100% alert when spending reaches 100%', () {
      final alerts = service.checkThresholds(
        previousTransactions: [expense(950, today)],
        currentTransactions: [expense(1000, today)],
        today: today,
        weeklyLimit: 1000,
        alert80Enabled: true,
        alert100Enabled: true,
      );

      expect(alerts.length, 1);
      expect(alerts.first.percent, 100);
      expect(alerts.first.remaining, 0);
    });

    test('does not repeat an alert when already above its threshold', () {
      final alerts = service.checkThresholds(
        previousTransactions: [expense(800, today)],
        currentTransactions: [expense(850, today)],
        today: today,
        weeklyLimit: 1000,
        alert80Enabled: true,
        alert100Enabled: true,
      );

      expect(alerts, isEmpty);
    });

    test('does not trigger disabled alerts', () {
      final alerts = service.checkThresholds(
        previousTransactions: [expense(750, today)],
        currentTransactions: [expense(800, today)],
        today: today,
        weeklyLimit: 1000,
        alert80Enabled: false,
        alert100Enabled: true,
      );

      expect(alerts, isEmpty);
    });

    test('can trigger both alerts when one transaction crosses both', () {
      final alerts = service.checkThresholds(
        previousTransactions: [expense(700, today)],
        currentTransactions: [expense(1100, today)],
        today: today,
        weeklyLimit: 1000,
        alert80Enabled: true,
        alert100Enabled: true,
      );

      expect(alerts.map((alert) => alert.percent), [80, 100]);
      expect(alerts.first.overspent, 100);
    });

    test('ignores income transactions', () {
      final alerts = service.checkThresholds(
        previousTransactions: [],
        currentTransactions: [
          income(1000, today),
        ],
        today: today,
        weeklyLimit: 1000,
        alert80Enabled: true,
        alert100Enabled: true,
      );

      expect(alerts, isEmpty);
    });

    test('ignores expenses outside the current week', () {
      final lastWeek = today.subtract(const Duration(days: 7));

      final alerts = service.checkThresholds(
        previousTransactions: [],
        currentTransactions: [
          expense(1000, lastWeek),
        ],
        today: today,
        weeklyLimit: 1000,
        alert80Enabled: true,
        alert100Enabled: true,
      );

      expect(alerts, isEmpty);
    });

    test('returns no alerts for an invalid budget limit', () {
      final alerts = service.checkThresholds(
        previousTransactions: [],
        currentTransactions: [expense(1000, today)],
        today: today,
        weeklyLimit: 0,
        alert80Enabled: true,
        alert100Enabled: true,
      );

      expect(alerts, isEmpty);
    });
  });
}
