import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/services/budget_settings.dart';

void main() {
  group('budgetAlertLevels', () {
    test('has an 80% alert and a 100% alert', () {
      expect(budgetAlertLevels.map((level) => level.percent).toList(), [80, 100]);
    });
  });

  group('BudgetAlertLevel', () {
    test('amountFor works out the amount where the alert goes off', () {
      expect(const BudgetAlertLevel(80).amountFor(4000), 3200);
      expect(const BudgetAlertLevel(80).amountFor(1000), 800);
      expect(const BudgetAlertLevel(80).amountFor(2500), 2000);
      expect(const BudgetAlertLevel(100).amountFor(1000), 1000);
      expect(const BudgetAlertLevel(80).amountFor(0), 0);
    });

    test('labelFor writes the text shown next to the switch', () {
      expect(const BudgetAlertLevel(80).labelFor(1000), 'Notify at 80% (₱800.00)');
      expect(const BudgetAlertLevel(80).labelFor(4000), 'Notify at 80% (₱3,200.00)');
      expect(
        const BudgetAlertLevel(100).labelFor(10000),
        'Notify at 100% (₱10,000.00)',
      );
      expect(const BudgetAlertLevel(80).labelFor(0), 'Notify at 80% (₱0.00)');
    });

    test('labelFor rounds to centavos', () {
      expect(const BudgetAlertLevel(80).labelFor(1234.5), 'Notify at 80% (₱987.60)');
    });
  });

  group('amount field text', () {
    test('formatBudgetField adds commas and two decimals, without the peso sign',
        () {
      expect(formatBudgetField(4000), '4,000.00');
      expect(formatBudgetField(1234567.5), '1,234,567.50');
      expect(formatBudgetField(0), '0.00');
    });

    test('editableBudgetText has no commas, so it is easy to type over', () {
      expect(editableBudgetText(4000), '4000.00');
      expect(editableBudgetText(2500.5), '2500.50');
      expect(editableBudgetText(0), '0.00');
    });
  });
}
