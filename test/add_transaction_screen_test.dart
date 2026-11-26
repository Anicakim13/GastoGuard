
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/services/budget_settings_scope.dart';
import 'package:gastoguard/services/budget_settings_store.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/services/transaction_store.dart';
import 'package:gastoguard/theme/app_theme.dart';
import 'package:gastoguard/widgets/category_card.dart';
import 'package:gastoguard/widgets/pill_toggle.dart';

void main() {
  final testDate = DateTime(2026, 11, 25);

  Future<void> pumpScreen(WidgetTester tester, Size logicalSize) async {
    tester.view.physicalSize = logicalSize * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AddTransactionScreen(initialDate: testDate),
      ),
    );
  }

  Future<void> pumpBudgetAlertScreen(
    WidgetTester tester, {
    bool alert80Enabled = true,
    bool alert100Enabled = true,
  }) async {
    tester.view.physicalSize = const Size(393, 852) * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final transactionStore = TransactionStore();
    final budgetStore = BudgetSettingsStore();

    addTearDown(transactionStore.dispose);
    addTearDown(budgetStore.dispose);

    await budgetStore.saveSettings(
      weeklyLimit: 1000,
      monthlyLimit: 4000,
      alert80Enabled: alert80Enabled,
      alert100Enabled: alert100Enabled,
    );

    await tester.pumpWidget(
      TransactionScope(
        store: transactionStore,
        child: BudgetSettingsScope(
          store: budgetStore,
          child: MaterialApp(
            theme: AppTheme.light,
            home: AddTransactionScreen(
              initialDate: testDate,
              currentTime: () => DateTime(2026, 11, 25, 12),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveExpense(
    WidgetTester tester,
    String amount,
  ) async {
    await tester.enterText(find.byType(TextField).first, amount);
    await tester.tap(find.text('Food'));
    await tester.tap(find.text('Save Transaction'));
    await tester.pumpAndSettle();
  }

  testWidgets('Add Transaction shows every part of the design',
      (WidgetTester tester) async {
    await pumpScreen(tester, const Size(393, 852));

    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Transportation'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('School Supplies'), findsOneWidget);
    expect(find.text('Entertainment'), findsOneWidget);
    expect(find.text('Others'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Nov 25, 2026'), findsOneWidget);
    expect(find.text('Note (Optional)'), findsOneWidget);
    expect(find.text('Save Transaction'), findsOneWidget);
  });

  testWidgets('Toggle and category cards change their selection',
      (WidgetTester tester) async {
    await pumpScreen(tester, const Size(393, 852));

    expect(tester.widget<PillToggle>(find.byType(PillToggle)).selectedIndex, 0);
    expect(
      tester
          .widget<CategoryCard>(find.widgetWithText(CategoryCard, 'Food'))
          .selected,
      isFalse,
    );

    await tester.tap(find.text('Income'));
    await tester.pump();
    expect(tester.widget<PillToggle>(find.byType(PillToggle)).selectedIndex, 1);

    await tester.tap(find.text('Food'));
    await tester.pump();
    expect(
      tester
          .widget<CategoryCard>(find.widgetWithText(CategoryCard, 'Food'))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<CategoryCard>(find.widgetWithText(CategoryCard, 'Data'))
          .selected,
      isFalse,
    );
  });

  testWidgets('Amount field accepts at most two decimals',
      (WidgetTester tester) async {
    await pumpScreen(tester, const Size(393, 852));

    await tester.enterText(find.byType(TextField).first, '12.345');
    await tester.pump();
    expect(find.text('12.34'), findsOneWidget);
  });

  testWidgets('Add Transaction does not overflow on a small phone',
      (WidgetTester tester) async {
    await pumpScreen(tester, const Size(320, 568));
    expect(find.text('Save Transaction'), findsOneWidget);
  });

  testWidgets('Add Transaction does not overflow on a wide web window',
      (WidgetTester tester) async {
    await pumpScreen(tester, const Size(1280, 800));
    expect(find.text('Save Transaction'), findsOneWidget);
  });

  testWidgets('Shows an 80% budget alert when weekly spending reaches 80%',
      (WidgetTester tester) async {
    await pumpBudgetAlertScreen(tester);

    await saveExpense(tester, '800');

    expect(find.text('Budget Alert!'), findsOneWidget);
    expect(find.textContaining('You’ve reached 80%'), findsOneWidget);
    expect(find.textContaining('₱200.00 left'), findsOneWidget);
  });

  testWidgets('Shows a 100% budget alert when the 100% threshold is crossed',
      (WidgetTester tester) async {
    await pumpBudgetAlertScreen(
      tester,
      alert80Enabled: false,
      alert100Enabled: true,
    );

    await saveExpense(tester, '1000');

    expect(find.text('Budget Alert!'), findsOneWidget);
    expect(find.textContaining('You’ve reached 100%'), findsOneWidget);
    expect(find.textContaining('₱0.00 left'), findsOneWidget);
  });

  testWidgets('Does not show an alert when both thresholds are disabled',
      (WidgetTester tester) async {
    await pumpBudgetAlertScreen(
      tester,
      alert80Enabled: false,
      alert100Enabled: false,
    );

    await saveExpense(tester, '800');

    expect(find.text('Budget Alert!'), findsNothing);
  });

  testWidgets('Does not show a budget alert when saving income',
      (WidgetTester tester) async {
    await pumpBudgetAlertScreen(tester);

    await tester.tap(find.text('Income'));
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.tap(find.text('Food'));
    await tester.tap(find.text('Save Transaction'));
    await tester.pumpAndSettle();

    expect(find.text('Budget Alert!'), findsNothing);
  });
}
