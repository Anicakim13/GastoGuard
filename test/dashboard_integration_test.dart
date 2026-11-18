import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/main.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/screens/dashboard_screen.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/services/transaction_store.dart';
import 'package:gastoguard/theme/app_theme.dart';

void main() {
  void usePhoneScreen(WidgetTester tester, [Size size = const Size(393, 852)]) {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // The Dashboard, sharing [store] like the real app does.
  Future<void> pumpDashboard(
    WidgetTester tester,
    TransactionStore store, {
    Size size = const Size(393, 852),
  }) async {
    usePhoneScreen(tester, size);
    await tester.pumpWidget(
      TransactionScope(
        store: store,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const DashboardScreen(),
        ),
      ),
    );
  }

  void addIncome(TransactionStore store, double amount) {
    store.addTransaction(
      category: TransactionCategory.others,
      amount: amount,
      isExpense: false,
      dateTime: DateTime(2026, 11, 9, 12, 0),
    );
  }

  void addExpense(
    TransactionStore store,
    TransactionCategory category,
    double amount,
  ) {
    store.addTransaction(
      category: category,
      amount: amount,
      isExpense: true,
      dateTime: DateTime(2026, 11, 9, 12, 0),
    );
  }

  testWidgets('Dashboard shows the totals worked out from the transactions',
      (WidgetTester tester) async {
    // The 14 sample transactions: income 3,000 and expenses 1,465.
    await pumpDashboard(
      tester,
      TransactionStore.withDemoData(DateTime(2026, 11, 15)),
    );

    expect(find.text('Remaining Balance'), findsOneWidget);
    expect(find.text('₱ 1,535.00'), findsOneWidget); // 3,000 - 1,465
    expect(find.text('51%'), findsOneWidget); // 1,535 of 3,000 is left
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('₱3,000.00'), findsOneWidget);
    expect(find.text('Spent'), findsOneWidget);
    expect(find.text('₱1,465.00'), findsOneWidget);
    // The pie legend: Food 24%, Transport 6%, Data 11%, Others 59%.
    expect(find.text('24%'), findsOneWidget);
    expect(find.text('6%'), findsOneWidget);
    expect(find.text('11%'), findsOneWidget);
    expect(find.text('59%'), findsOneWidget);
    // The weekly budget is still the sample value.
    expect(find.text('Weekly Budget: ₱ 1,000.00'), findsOneWidget);
  });

  testWidgets('Dashboard refreshes by itself when a transaction is added',
      (WidgetTester tester) async {
    final store = TransactionStore(); // starts empty
    await pumpDashboard(tester, store);

    // Nothing yet: balance 0, Income 0, Spent 0, and 0% five times
    // (the balance bar plus the four pie categories).
    expect(find.text('₱ 0.00'), findsOneWidget);
    expect(find.text('₱0.00'), findsNWidgets(2));
    expect(find.text('0%'), findsNWidgets(5));

    // Income of 1,000: the whole income is still left.
    addIncome(store, 1000);
    await tester.pump();
    expect(find.text('₱ 1,000.00'), findsOneWidget);
    expect(find.text('₱1,000.00'), findsOneWidget); // the Income card
    expect(find.text('100%'), findsOneWidget); // the balance bar

    // A Food expense of 150: 850 is left, and Food is all of the spending.
    addExpense(store, TransactionCategory.food, 150);
    await tester.pump();
    expect(find.text('₱ 850.00'), findsOneWidget);
    expect(find.text('₱150.00'), findsOneWidget); // the Spent card
    expect(find.text('85%'), findsOneWidget); // the balance bar
    expect(find.text('100%'), findsOneWidget); // Food in the pie legend

    // An Entertainment expense of 50 counts in "Others": 75% Food, 25% Others.
    addExpense(store, TransactionCategory.entertainment, 50);
    await tester.pump();
    expect(find.text('₱ 800.00'), findsOneWidget);
    expect(find.text('₱200.00'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
  });

  testWidgets('A negative balance is shown with a minus sign',
      (WidgetTester tester) async {
    final store = TransactionStore();
    addIncome(store, 100);
    addExpense(store, TransactionCategory.food, 300);
    await pumpDashboard(tester, store);

    expect(find.text('-₱ 200.00'), findsOneWidget);
    expect(find.text('₱300.00'), findsOneWidget);
  });

  testWidgets('Very large amounts do not overflow on a small phone',
      (WidgetTester tester) async {
    final store = TransactionStore();
    addIncome(store, 1234567.89);
    addExpense(store, TransactionCategory.data, 987654.32);
    await pumpDashboard(tester, store, size: const Size(320, 568));

    // flutter_test fails the test by itself if a layout overflow happens.
    expect(find.text('₱ 246,913.57'), findsOneWidget);
    expect(find.text('₱1,234,567.89'), findsOneWidget);
    expect(find.text('₱987,654.32'), findsOneWidget);
  });

  testWidgets('A transaction saved in the app updates the Dashboard',
      (WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const GastoGuardApp());

    // Splash -> Dashboard, showing the totals of the 14 sample transactions.
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();
    expect(find.text('₱ 1,535.00'), findsOneWidget);
    expect(find.text('₱3,000.00'), findsOneWidget);
    expect(find.text('₱1,465.00'), findsOneWidget);
    expect(find.text('51%'), findsOneWidget);

    // Add a Food expense of 100 and save it.
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.tap(find.text('Food'));
    await tester.pump();
    await tester.tap(find.text('Save Transaction'));
    await tester.pumpAndSettle();

    // Back on the Dashboard, the numbers have already changed.
    expect(find.byType(AddTransactionScreen), findsNothing);
    expect(find.text('₱ 1,435.00'), findsOneWidget); // 3,000 - 1,565
    expect(find.text('₱3,000.00'), findsOneWidget); // income did not change
    expect(find.text('₱1,565.00'), findsOneWidget); // 1,465 + 100
    expect(find.text('48%'), findsOneWidget); // 1,435 of 3,000
    // Pie legend: Food 29%, Transport 6%, Data 10%, Others 55%.
    expect(find.text('29%'), findsOneWidget);
    expect(find.text('6%'), findsOneWidget);
    expect(find.text('10%'), findsOneWidget);
    expect(find.text('55%'), findsOneWidget);
  });
}
