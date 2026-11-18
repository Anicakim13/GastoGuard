import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/main.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/screens/dashboard_screen.dart';
import 'package:gastoguard/screens/history_screen.dart';
import 'package:gastoguard/services/transaction_filter.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/services/transaction_store.dart';
import 'package:gastoguard/theme/app_theme.dart';
import 'package:gastoguard/widgets/app_dropdown.dart';
import 'package:gastoguard/widgets/transaction_tile.dart';

void main() {
  // Pretend to be a typical phone (393 x 852 logical pixels).
  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  final rows = find.byType(TransactionTile);

  // Text inside a transaction row.
  Finder inRows(String text) =>
      find.descendant(of: rows, matching: find.text(text));

  testWidgets('History updates by itself when a transaction is added',
      (WidgetTester tester) async {
    usePhoneScreen(tester);
    final today = DateTime(2026, 11, 15);
    final store = TransactionStore.withDemoData(today);
    await tester.pumpWidget(
      TransactionScope(
        store: store,
        child: MaterialApp(
          theme: AppTheme.light,
          home: HistoryScreen(today: today),
        ),
      ),
    );
    expect(rows, findsNWidgets(5)); // the sample transactions of "This Month"

    store.addTransaction(
      category: TransactionCategory.food,
      amount: 99,
      isExpense: true,
      dateTime: DateTime(2026, 11, 20, 9, 5),
    );
    await tester.pump();

    expect(rows, findsNWidgets(6));
    expect(inRows('-₱99.00'), findsOneWidget);
    expect(inRows('November 20, 9:05 AM'), findsOneWidget);
  });

  testWidgets('A transaction from another month shows under that month',
      (WidgetTester tester) async {
    usePhoneScreen(tester);
    final today = DateTime(2026, 11, 15);
    final store = TransactionStore.withDemoData(today);
    await tester.pumpWidget(
      TransactionScope(
        store: store,
        child: MaterialApp(
          theme: AppTheme.light,
          home: HistoryScreen(today: today),
        ),
      ),
    );

    store.addTransaction(
      category: TransactionCategory.others,
      amount: 250,
      isExpense: false,
      dateTime: DateTime(2026, 10, 5, 14, 30),
    );
    await tester.pump();

    // Not in "This Month"...
    expect(rows, findsNWidgets(5));
    expect(inRows('+₱250.00'), findsNothing);

    // ...but in "Last Month".
    await tester.tap(find.byType(AppDropdown<HistoryPeriod>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last Month').last);
    await tester.pumpAndSettle();
    expect(rows, findsNWidgets(6));
    expect(inRows('+₱250.00'), findsOneWidget);
    expect(inRows('October 05, 2:30 PM'), findsOneWidget);
  });

  testWidgets('A transaction saved in the app appears in History',
      (WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const GastoGuardApp());

    // Splash -> Dashboard -> Add Transaction
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionScreen), findsOneWidget);

    // Fill in an expense and save it.
    await tester.enterText(find.byType(TextField).first, '75.5');
    await tester.tap(find.text('Food'));
    await tester.pump();
    await tester.tap(find.text('Save Transaction'));
    await tester.pumpAndSettle();

    // Back on the Dashboard, with a confirmation message.
    expect(find.byType(AddTransactionScreen), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Transaction saved'), findsOneWidget);

    // Let the message disappear, then open History.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    // The 5 sample transactions of this month plus the new one.
    expect(rows, findsNWidgets(6));
    expect(inRows('-₱75.50'), findsOneWidget);
    // The new row is a Food transaction.
    final newRow = find.ancestor(
      of: find.text('-₱75.50'),
      matching: find.byType(TransactionTile),
    );
    expect(
      find.descendant(of: newRow, matching: find.text('Food')),
      findsOneWidget,
    );
  });
}
