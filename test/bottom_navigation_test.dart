import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/main.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/screens/dashboard_screen.dart';
import 'package:gastoguard/screens/history_screen.dart';
import 'package:gastoguard/screens/spending_summary_screen.dart';
import 'package:gastoguard/theme/app_theme.dart';

void main() {
  // Pretend to be a typical phone (393 x 852 logical pixels).
  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // The Dashboard as the first screen, like in the real app.
  Future<Element> pumpDashboard(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const DashboardScreen()),
    );
    return tester.element(find.byType(DashboardScreen));
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  // Checks that the Dashboard shown now is [original], not a second copy,
  // and that there is nowhere further back to go.
  void expectBackOnTheSameDashboard(WidgetTester tester, Element original) {
    expect(find.byType(DashboardScreen, skipOffstage: false), findsOneWidget);
    expect(tester.element(find.byType(DashboardScreen)), same(original));
    expect(Navigator.of(original).canPop(), isFalse);
  }

  testWidgets('The Summary item on the Dashboard opens the Spending Summary',
      (WidgetTester tester) async {
    final dashboard = await pumpDashboard(tester);

    await tapAndSettle(tester, find.text('Summary'));
    expect(find.byType(SpendingSummaryScreen), findsOneWidget);
    expect(find.text('Spending Summary'), findsOneWidget);

    // The back arrow returns to the same Dashboard.
    await tapAndSettle(tester, find.byTooltip('Back'));
    expect(find.byType(SpendingSummaryScreen), findsNothing);
    expectBackOnTheSameDashboard(tester, dashboard);
  });

  testWidgets('The View Details button on the Dashboard opens the Spending Summary',
      (WidgetTester tester) async {
    await pumpDashboard(tester);

    await tester.ensureVisible(find.text('View Details'));
    await tapAndSettle(tester, find.text('View Details'));

    expect(find.byType(SpendingSummaryScreen), findsOneWidget);
  });

  testWidgets('Home in the Summary bottom bar returns to the Dashboard',
      (WidgetTester tester) async {
    final dashboard = await pumpDashboard(tester);
    await tapAndSettle(tester, find.text('Summary'));

    await tapAndSettle(tester, find.text('Home'));

    expect(find.byType(SpendingSummaryScreen), findsNothing);
    expectBackOnTheSameDashboard(tester, dashboard);
  });

  testWidgets('History in the Summary bottom bar swaps to History',
      (WidgetTester tester) async {
    final dashboard = await pumpDashboard(tester);
    await tapAndSettle(tester, find.text('Summary'));

    await tapAndSettle(tester, find.text('History'));
    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.byType(SpendingSummaryScreen), findsNothing);

    // History's back arrow goes straight to the Dashboard, not to Summary.
    await tapAndSettle(tester, find.byTooltip('Back'));
    expect(find.byType(HistoryScreen), findsNothing);
    expect(find.byType(SpendingSummaryScreen), findsNothing);
    expectBackOnTheSameDashboard(tester, dashboard);
  });

  testWidgets('Summary in the History bottom bar swaps to the Spending Summary',
      (WidgetTester tester) async {
    final dashboard = await pumpDashboard(tester);
    await tapAndSettle(tester, find.text('History'));

    await tapAndSettle(tester, find.text('Summary'));
    expect(find.byType(SpendingSummaryScreen), findsOneWidget);
    expect(find.byType(HistoryScreen), findsNothing);

    await tapAndSettle(tester, find.byTooltip('Back'));
    expect(find.byType(SpendingSummaryScreen), findsNothing);
    expectBackOnTheSameDashboard(tester, dashboard);
  });

  testWidgets('Add in the Summary bottom bar opens Add Transaction and back returns',
      (WidgetTester tester) async {
    await pumpDashboard(tester);
    await tapAndSettle(tester, find.text('Summary'));

    await tapAndSettle(tester, find.text('Add'));
    expect(find.byType(AddTransactionScreen), findsOneWidget);

    await tapAndSettle(tester, find.byTooltip('Back'));
    expect(find.byType(AddTransactionScreen), findsNothing);
    expect(find.byType(SpendingSummaryScreen), findsOneWidget);
  });

  testWidgets('Add in the History bottom bar opens Add Transaction and back returns',
      (WidgetTester tester) async {
    await pumpDashboard(tester);
    await tapAndSettle(tester, find.text('History'));

    await tapAndSettle(tester, find.text('Add'));
    expect(find.byType(AddTransactionScreen), findsOneWidget);

    await tapAndSettle(tester, find.byTooltip('Back'));
    expect(find.byType(AddTransactionScreen), findsNothing);
    expect(find.byType(HistoryScreen), findsOneWidget);
  });

  testWidgets('Tapping the item of the screen you are on does nothing',
      (WidgetTester tester) async {
    final dashboard = await pumpDashboard(tester);
    await tapAndSettle(tester, find.text('Summary'));

    await tapAndSettle(tester, find.text('Summary')); // already here
    expect(find.byType(SpendingSummaryScreen), findsOneWidget);

    // One back press still leads to the Dashboard: no extra screen was added.
    await tapAndSettle(tester, find.byTooltip('Back'));
    expectBackOnTheSameDashboard(tester, dashboard);
  });

  testWidgets('An expense saved from the Summary shows up in the Summary',
      (WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const GastoGuardApp());

    // Splash -> Dashboard -> Spending Summary (sample data: 470 this month).
    await tapAndSettle(tester, find.text('GET STARTED'));
    await tapAndSettle(tester, find.text('Summary'));
    expect(find.text('₱470.00'), findsOneWidget);
    // At first School Supplies is the top category: 210 of 470 is 45%.
    expect(find.text('School Supplies'), findsOneWidget);
    expect(find.text('₱210.00 (45%)'), findsOneWidget);

    // Add a Food expense of 100 from the Summary's own bottom bar.
    await tapAndSettle(tester, find.text('Add'));
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.tap(find.text('Food'));
    await tester.pump();
    await tester.tap(find.text('Save Transaction'));
    await tester.pumpAndSettle();

    // Back on the Summary, the total has already grown (470 + 100).
    expect(find.byType(AddTransactionScreen), findsNothing);
    expect(find.byType(SpendingSummaryScreen), findsOneWidget);
    expect(find.text('₱570.00'), findsOneWidget);
    // Food already had 150 this month, so it is now 150 + 100 = 250. That is
    // more than School Supplies (210), so Food takes over as the top
    // category: 250 of 570 is 44%.
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('₱250.00 (44%)'), findsOneWidget);
    expect(find.text('School Supplies'), findsNothing);
  });
}
