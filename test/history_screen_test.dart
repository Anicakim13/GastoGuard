import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/screens/dashboard_screen.dart';
import 'package:gastoguard/screens/history_screen.dart';
import 'package:gastoguard/services/transaction_filter.dart';
import 'package:gastoguard/theme/app_theme.dart';
import 'package:gastoguard/widgets/app_bottom_nav.dart';
import 'package:gastoguard/widgets/app_dropdown.dart';
import 'package:gastoguard/widgets/transaction_tile.dart';

void main() {
  // "Today" is fixed, so the demo data and month names never change:
  // this month = November 2026, last month = October 2026, and so on.
  final today = DateTime(2026, 11, 15);

  void usePhoneScreen(WidgetTester tester, Size logicalSize) {
    tester.view.physicalSize = logicalSize * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpHistory(
    WidgetTester tester, {
    Size size = const Size(393, 852),
  }) async {
    usePhoneScreen(tester, size);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: HistoryScreen(today: today)),
    );
  }

  // How many transaction rows are on the screen?
  final rows = find.byType(TransactionTile);

  // Text inside a transaction row (so it is not confused with the dropdowns).
  Finder inRows(String text) =>
      find.descendant(of: rows, matching: find.text(text));

  // Opens a dropdown and picks a choice. The open menu is drawn last, so
  // ".last" is the menu item and not a copy of the same text elsewhere.
  Future<void> pickFromDropdown(
    WidgetTester tester,
    Finder dropdown,
    String choice,
  ) async {
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(choice).last);
    await tester.pumpAndSettle();
  }

  final categoryDropdown = find.byType(AppDropdown<TransactionCategory?>);
  final periodDropdown = find.byType(AppDropdown<HistoryPeriod>);

  testWidgets('History shows every part of the design',
      (WidgetTester tester) async {
    await pumpHistory(tester);

    expect(find.text('Transaction History'), findsOneWidget);
    expect(find.text('Search Transactions'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(categoryDropdown, findsOneWidget);
    expect(periodDropdown, findsOneWidget);
    expect(find.byType(AppBottomNav), findsOneWidget);

    // "This Month" is selected at first: one month heading, five rows.
    expect(find.text('November 2026'), findsOneWidget);
    expect(rows, findsNWidgets(5));
    expect(inRows('Food'), findsOneWidget);
    expect(inRows('Transportation'), findsOneWidget);
    expect(inRows('School Supplies'), findsOneWidget);
    expect(inRows('Data'), findsOneWidget);
    expect(inRows('November 08, 8:00 AM'), findsOneWidget);
    expect(inRows('-₱150.00'), findsOneWidget);
    expect(inRows('-₱50.00'), findsOneWidget);
    expect(inRows('-₱210.00'), findsOneWidget);
    expect(inRows('-₱60.00'), findsOneWidget);
    expect(inRows('+₱1,000.00'), findsOneWidget);
  });

  testWidgets('Expense amounts are red', (WidgetTester tester) async {
    await pumpHistory(tester);

    final expense = tester.widget<Text>(inRows('-₱150.00'));
    expect(expense.style?.color, const Color(0xFFFF3131));
    final income = tester.widget<Text>(inRows('+₱1,000.00'));
    expect(income.style?.color, isNot(const Color(0xFFFF3131)));
  });

  testWidgets('Search filters the transactions', (WidgetTester tester) async {
    await pumpHistory(tester);
    final searchBox = find.byType(TextField);

    await tester.enterText(searchBox, 'transport');
    await tester.pump();
    expect(rows, findsOneWidget);
    expect(inRows('Transportation'), findsOneWidget);

    // Upper case works too.
    await tester.enterText(searchBox, 'FOOD');
    await tester.pump();
    expect(rows, findsOneWidget);
    expect(inRows('Food'), findsOneWidget);

    // Search by amount.
    await tester.enterText(searchBox, '210');
    await tester.pump();
    expect(rows, findsOneWidget);
    expect(inRows('School Supplies'), findsOneWidget);

    // Search by date: both words must match.
    await tester.enterText(searchBox, 'november 17');
    await tester.pump();
    expect(rows, findsOneWidget);
    expect(inRows('School Supplies'), findsOneWidget);

    // Nothing matches.
    await tester.enterText(searchBox, 'zzz');
    await tester.pump();
    expect(rows, findsNothing);
    expect(find.text('No transactions found'), findsOneWidget);

    // Clearing the search brings everything back.
    await tester.enterText(searchBox, '');
    await tester.pump();
    expect(rows, findsNWidgets(5));
    expect(find.text('No transactions found'), findsNothing);
  });

  testWidgets('All, Income, and Expense chips filter the transactions',
      (WidgetTester tester) async {
    await pumpHistory(tester);

    await tester.tap(find.text('Income'));
    await tester.pump();
    expect(rows, findsOneWidget);
    expect(inRows('+₱1,000.00'), findsOneWidget);

    await tester.tap(find.text('Expense'));
    await tester.pump();
    expect(rows, findsNWidgets(4));
    expect(inRows('+₱1,000.00'), findsNothing);

    await tester.tap(find.text('All'));
    await tester.pump();
    expect(rows, findsNWidgets(5));
  });

  testWidgets('The category dropdown filters by category',
      (WidgetTester tester) async {
    await pumpHistory(tester);

    await pickFromDropdown(tester, categoryDropdown, 'Food');
    expect(rows, findsOneWidget);
    expect(inRows('Food'), findsOneWidget);
    expect(inRows('Transportation'), findsNothing);

    await pickFromDropdown(tester, categoryDropdown, 'All Categories');
    expect(rows, findsNWidgets(5));
  });

  testWidgets('The month dropdown changes which months are shown',
      (WidgetTester tester) async {
    await pumpHistory(tester);

    await pickFromDropdown(tester, periodDropdown, 'Last Month');
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('November 2026'), findsNothing);
    expect(rows, findsNWidgets(5));

    await pickFromDropdown(tester, periodDropdown, 'Last 3 Months');
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('August 2026'), findsNothing);
    expect(rows, findsNWidgets(13));

    await pickFromDropdown(tester, periodDropdown, 'All Time');
    expect(find.text('August 2026'), findsOneWidget);
    expect(rows, findsNWidgets(14));

    await pickFromDropdown(tester, periodDropdown, 'This Month');
    expect(find.text('November 2026'), findsOneWidget);
    expect(rows, findsNWidgets(5));
  });

  testWidgets('Search, chips, and dropdowns work together',
      (WidgetTester tester) async {
    await pumpHistory(tester);

    await pickFromDropdown(tester, periodDropdown, 'All Time');
    await tester.tap(find.text('Expense'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'transportation');
    await tester.pump();

    // Transportation expenses in every month: November and October.
    expect(rows, findsNWidgets(2));
  });

  testWidgets('History opens from the Dashboard and the back arrow returns',
      (WidgetTester tester) async {
    usePhoneScreen(tester, const Size(393, 852));
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const DashboardScreen()),
    );
    final dashboardBefore = tester.element(find.byType(DashboardScreen));

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.text('Transaction History'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsNothing);
    // It is the very same Dashboard as before, not a new copy.
    expect(find.byType(DashboardScreen, skipOffstage: false), findsOneWidget);
    expect(
      tester.element(find.byType(DashboardScreen)),
      same(dashboardBefore),
    );
  });

  testWidgets('The Home item in the History bottom bar returns to the Dashboard',
      (WidgetTester tester) async {
    usePhoneScreen(tester, const Size(393, 852));
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const DashboardScreen()),
    );

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsNothing);
    expect(find.byType(DashboardScreen, skipOffstage: false), findsOneWidget);
  });

  testWidgets('Back arrow does nothing when History is the only screen',
      (WidgetTester tester) async {
    await pumpHistory(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('History does not overflow on a small phone',
      (WidgetTester tester) async {
    await pumpHistory(tester, size: const Size(320, 568));
    // flutter_test fails the test by itself if a layout overflow happens.
    expect(find.text('Transaction History'), findsOneWidget);
    expect(rows, findsNWidgets(5));
  });

  testWidgets('History does not overflow on a wide web window',
      (WidgetTester tester) async {
    await pumpHistory(tester, size: const Size(1280, 800));
    expect(find.text('Transaction History'), findsOneWidget);
    expect(rows, findsNWidgets(5));
  });
}
