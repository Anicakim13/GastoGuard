import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/main.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/screens/dashboard_screen.dart';
import 'package:gastoguard/screens/splash_screen.dart';
import 'package:gastoguard/theme/app_theme.dart';

void main() {
  // Pretend to be a typical phone (393 x 852 logical pixels).
  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// The whole app, starting at the Splash Screen.
  Future<void> pumpApp(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(const GastoGuardApp());
  }

  /// Just a screen inside a MaterialApp (like the preview files do).
  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: screen));
  }

  testWidgets('GET STARTED opens the Dashboard and replaces the Splash Screen',
      (WidgetTester tester) async {
    await pumpApp(tester);
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    // The Splash Screen was replaced, so there is nothing to go back to.
    final navigator =
        Navigator.of(tester.element(find.byType(DashboardScreen)));
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('The Add item in the Dashboard bottom bar opens Add Transaction',
      (WidgetTester tester) async {
    await pumpScreen(tester, const DashboardScreen());
    expect(find.byType(AddTransactionScreen), findsNothing);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(find.text('Add Transaction'), findsOneWidget);
    // The Dashboard stays underneath (hidden), ready to be returned to.
    expect(find.byType(DashboardScreen, skipOffstage: false), findsOneWidget);
  });

  testWidgets('The back arrow returns to the same Dashboard (no duplicate)',
      (WidgetTester tester) async {
    await pumpScreen(tester, const DashboardScreen());
    final dashboardBefore = tester.element(find.byType(DashboardScreen));

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(AddTransactionScreen), findsNothing);
    expect(find.byType(DashboardScreen, skipOffstage: false), findsOneWidget);
    // It is the very same Dashboard as before, not a new copy.
    expect(
      tester.element(find.byType(DashboardScreen)),
      same(dashboardBefore),
    );
  });

  testWidgets('Full flow: Splash, Dashboard, Add Transaction, and back',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionScreen), findsNothing);
    expect(find.byType(DashboardScreen, skipOffstage: false), findsOneWidget);
    expect(find.byType(SplashScreen, skipOffstage: false), findsNothing);

    // Back on the Dashboard there is nowhere further back to go.
    final navigator =
        Navigator.of(tester.element(find.byType(DashboardScreen)));
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('Home in the Dashboard bottom bar does nothing',
      (WidgetTester tester) async {
    await pumpScreen(tester, const DashboardScreen());

    // (Add, History, and Summary open their own screens; see
    // bottom_navigation_test.dart.)
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(AddTransactionScreen), findsNothing);
  });

  testWidgets('Back arrow does nothing when Add Transaction is the only screen',
      (WidgetTester tester) async {
    await pumpScreen(tester, const AddTransactionScreen());

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
