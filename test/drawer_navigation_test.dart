import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/main.dart';
import 'package:gastoguard/screens/about_screen.dart';
import 'package:gastoguard/screens/budget_settings_screen.dart';
import 'package:gastoguard/screens/dashboard_screen.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/services/transaction_store.dart';
import 'package:gastoguard/theme/app_theme.dart';

void main() {
  // Pretend to be a typical phone (393 x 852 logical pixels).
  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // The Dashboard as the first screen. Returns it, to check later that it is
  // still the very same one (not a second copy).
  Future<Element> pumpDashboard(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const DashboardScreen()),
    );
    return tester.element(find.byType(DashboardScreen));
  }

  // Taps the menu icon at the top left of the Dashboard.
  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
  }

  void expectBackOnTheSameDashboard(WidgetTester tester, Element original) {
    expect(find.byType(DashboardScreen, skipOffstage: false), findsOneWidget);
    expect(tester.element(find.byType(DashboardScreen)), same(original));
    expect(Navigator.of(original).canPop(), isFalse);
    expect(find.text('Renz'), findsNothing); // the drawer is closed
  }

  testWidgets('The menu icon opens the drawer', (WidgetTester tester) async {
    await pumpDashboard(tester);
    expect(find.text('Renz'), findsNothing); // closed at first

    await openMenu(tester);

    expect(find.text('Renz'), findsOneWidget);
    expect(find.text('Track. Smart. Spent Better'), findsOneWidget);
    expect(find.text('Budget Settings'), findsOneWidget);
    expect(find.text('About GastoGuard'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Delete Data'), findsOneWidget);
  });

  testWidgets('Budget Settings opens the real Budget Settings screen',
      (WidgetTester tester) async {
    final dashboard = await pumpDashboard(tester);
    await openMenu(tester);

    await tester.tap(find.text('Budget Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetSettingsScreen), findsOneWidget);

    // The back arrow returns to the same Dashboard, with the drawer closed.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetSettingsScreen), findsNothing);
    expectBackOnTheSameDashboard(tester, dashboard);
  });

  testWidgets('About GastoGuard opens the About screen',
      (WidgetTester tester) async {
    final dashboard = await pumpDashboard(tester);
    await openMenu(tester);

    await tester.tap(find.text('About GastoGuard'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsNothing);
    expectBackOnTheSameDashboard(tester, dashboard);
  });

  testWidgets('Dark Mode and Delete Data only show a message',
      (WidgetTester tester) async {
    final dashboard = await pumpDashboard(tester);

    // (Help & Support now opens its own screen; see
    // help_support_screen_test.dart.)
    for (final feature in ['Dark Mode', 'Delete Data']) {
      await openMenu(tester);
      await tester.tap(find.text(feature));
      await tester.pumpAndSettle();

      expect(find.text('$feature is coming soon'), findsOneWidget);
      // No other screen opened, and the drawer is closed again.
      expect(find.byType(BudgetSettingsScreen), findsNothing);
      expect(find.byType(AboutScreen), findsNothing);
      expectBackOnTheSameDashboard(tester, dashboard);
    }
  });

  testWidgets('Delete Data does not delete anything yet',
      (WidgetTester tester) async {
    usePhoneScreen(tester);
    final store = TransactionStore.withDemoData(DateTime(2026, 11, 15));
    await tester.pumpWidget(
      TransactionScope(
        store: store,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const DashboardScreen(),
        ),
      ),
    );
    expect(store.transactions.length, 14);
    expect(find.text('₱3,000.00'), findsOneWidget); // the Income card

    await openMenu(tester);
    await tester.tap(find.text('Delete Data'));
    await tester.pumpAndSettle();

    // All 14 transactions are still there and the Dashboard is unchanged.
    expect(store.transactions.length, 14);
    expect(find.text('₱3,000.00'), findsOneWidget);
    expect(find.text('₱1,465.00'), findsOneWidget); // the Spent card
  });

  testWidgets('Tapping outside the drawer closes it',
      (WidgetTester tester) async {
    await pumpDashboard(tester);
    await openMenu(tester);
    expect(find.text('Renz'), findsOneWidget);

    await tester.tapAt(const Offset(380, 600)); // to the right of the drawer
    await tester.pumpAndSettle();

    expect(find.text('Renz'), findsNothing);
  });

  testWidgets('The drawer works in the real app, one screen after another',
      (WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const GastoGuardApp());

    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();
    final dashboard = tester.element(find.byType(DashboardScreen));

    // Menu -> About -> back
    await openMenu(tester);
    await tester.tap(find.text('About GastoGuard'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // Menu -> Budget Settings -> back
    await openMenu(tester);
    await tester.tap(find.text('Budget Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetSettingsScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expectBackOnTheSameDashboard(tester, dashboard);
  });
}
