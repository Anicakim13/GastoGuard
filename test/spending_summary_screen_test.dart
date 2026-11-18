import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/screens/spending_summary_screen.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/services/transaction_store.dart';
import 'package:gastoguard/theme/app_theme.dart';
import 'package:gastoguard/widgets/app_bottom_nav.dart';
import 'package:gastoguard/widgets/pill_toggle.dart';
import 'package:gastoguard/widgets/spending_bar_chart.dart';

void main() {
  // "Today" is Monday, November 16, 2026, so "this week" is November 16-22.
  final today = DateTime(2026, 11, 16);

  void usePhoneScreen(WidgetTester tester, Size logicalSize) {
    tester.view.physicalSize = logicalSize * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // The screen on its own: it uses the sample transactions.
  Future<void> pumpSummary(
    WidgetTester tester, {
    Size size = const Size(393, 852),
  }) async {
    usePhoneScreen(tester, size);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: SpendingSummaryScreen(today: today),
      ),
    );
  }

  // The screen sharing [store], like the real app does.
  Future<void> pumpSummaryWith(
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
          home: SpendingSummaryScreen(today: today),
        ),
      ),
    );
  }

  List<double> chartValues(WidgetTester tester) =>
      tester.widget<SpendingBarChart>(find.byType(SpendingBarChart)).values;

  void addExpense(
    TransactionStore store,
    TransactionCategory category,
    double amount,
    DateTime when,
  ) {
    store.addTransaction(
      category: category,
      amount: amount,
      isExpense: true,
      dateTime: when,
    );
  }

  testWidgets('Spending Summary shows every part of the design',
      (WidgetTester tester) async {
    await pumpSummary(tester);

    expect(find.text('Spending Summary'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Total Spent'), findsOneWidget);
    expect(find.text('Budget Limit'), findsOneWidget);
    expect(find.text('Top Category'), findsOneWidget);

    // Monthly is selected at first, like the Canva design.
    expect(tester.widget<PillToggle>(find.byType(PillToggle)).selectedIndex, 1);

    // The sample transactions of this month: 470 spent in total.
    expect(find.text('₱470.00'), findsOneWidget);
    expect(find.text('₱4,000.00'), findsOneWidget);
    expect(find.text('School Supplies'), findsOneWidget);
    expect(find.text('₱210.00 (45%)'), findsOneWidget);

    // The chart: one bar for each week of the month, and its axis.
    expect(chartValues(tester), [0, 200, 210, 60, 0]);
    for (final label in ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5']) {
      expect(find.text(label), findsOneWidget);
    }
    for (final number in ['50', '100', '150', '200', '250']) {
      expect(find.text(number), findsOneWidget);
    }

    // The bottom bar, with Summary selected.
    final nav = tester.widget<AppBottomNav>(find.byType(AppBottomNav));
    expect(nav.currentIndex, AppBottomNav.summaryIndex);
  });

  testWidgets('The Weekly and Monthly tabs change the numbers',
      (WidgetTester tester) async {
    await pumpSummary(tester);

    await tester.tap(find.text('Weekly'));
    await tester.pump();

    expect(tester.widget<PillToggle>(find.byType(PillToggle)).selectedIndex, 0);
    for (final label in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
      expect(find.text(label), findsOneWidget);
    }
    // Only the 17th (a Tuesday) is in this week.
    expect(chartValues(tester), [0, 210, 0, 0, 0, 0, 0]);
    expect(find.text('₱210.00'), findsOneWidget); // Total Spent
    expect(find.text('₱1,000.00'), findsOneWidget); // the weekly Budget Limit
    expect(find.text('₱210.00 (100%)'), findsOneWidget); // Top Category

    await tester.tap(find.text('Monthly'));
    await tester.pump();
    expect(chartValues(tester), [0, 200, 210, 60, 0]);
    expect(find.text('₱470.00'), findsOneWidget);
    expect(find.text('₱4,000.00'), findsOneWidget);
  });

  testWidgets('The summary updates by itself when an expense is added',
      (WidgetTester tester) async {
    final store = TransactionStore(); // starts empty
    await pumpSummaryWith(tester, store);

    // Nothing spent yet.
    expect(find.text('₱0.00'), findsOneWidget);
    expect(find.text('No expenses yet'), findsOneWidget);
    expect(chartValues(tester), [0, 0, 0, 0, 0]);
    expect(find.text('1,000'), findsOneWidget); // the empty chart's top number

    // A Food expense on November 10 (Week 2).
    addExpense(store, TransactionCategory.food, 120, DateTime(2026, 11, 10, 12));
    await tester.pump();
    expect(find.text('₱120.00'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('₱120.00 (100%)'), findsOneWidget);
    expect(find.text('No expenses yet'), findsNothing);
    expect(chartValues(tester), [0, 120, 0, 0, 0]);

    // Income is NOT spending, so nothing changes.
    store.addTransaction(
      category: TransactionCategory.others,
      amount: 500,
      isExpense: false,
      dateTime: DateTime(2026, 11, 12, 12),
    );
    await tester.pump();
    expect(find.text('₱120.00'), findsOneWidget);
    expect(chartValues(tester), [0, 120, 0, 0, 0]);

    // A bigger Data expense on November 20 (Week 3) becomes the top category.
    addExpense(store, TransactionCategory.data, 180, DateTime(2026, 11, 20, 9));
    await tester.pump();
    expect(find.text('₱300.00'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('₱180.00 (60%)'), findsOneWidget);
    expect(chartValues(tester), [0, 120, 180, 0, 0]);
  });

  testWidgets('Expenses from other months are not counted',
      (WidgetTester tester) async {
    final store = TransactionStore();
    addExpense(store, TransactionCategory.food, 300, DateTime(2026, 10, 20, 12));
    addExpense(store, TransactionCategory.food, 400, DateTime(2025, 11, 20, 12));
    await pumpSummaryWith(tester, store);

    expect(find.text('₱0.00'), findsOneWidget);
    expect(find.text('No expenses yet'), findsOneWidget);
  });

  testWidgets('Spending Summary does not overflow on a small phone',
      (WidgetTester tester) async {
    await pumpSummary(tester, size: const Size(320, 568));
    // flutter_test fails the test by itself if a layout overflow happens.
    expect(find.text('Spending Summary'), findsOneWidget);
    expect(find.text('Top Category'), findsOneWidget);
  });

  testWidgets('Very large amounts and a long category name fit on a small phone',
      (WidgetTester tester) async {
    final store = TransactionStore();
    addExpense(
      store,
      TransactionCategory.entertainment,
      1234567.89,
      DateTime(2026, 11, 10, 12),
    );
    await pumpSummaryWith(tester, store, size: const Size(320, 568));

    expect(find.text('₱1,234,567.89'), findsOneWidget);
    expect(find.text('Entertainment'), findsOneWidget);
    expect(find.text('₱1,234,567.89 (100%)'), findsOneWidget);
  });

  testWidgets('Spending Summary does not overflow on a wide web window',
      (WidgetTester tester) async {
    await pumpSummary(tester, size: const Size(1280, 800));
    expect(find.text('Spending Summary'), findsOneWidget);
    expect(find.text('Top Category'), findsOneWidget);
  });
}
