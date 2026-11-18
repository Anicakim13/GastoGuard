import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/screens/dashboard_screen.dart';
import 'package:gastoguard/theme/app_theme.dart';

void main() {
  Future<void> pumpDashboard(WidgetTester tester, Size logicalSize) async {
    tester.view.physicalSize = logicalSize * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const DashboardScreen()),
    );
  }

  testWidgets('Dashboard shows the sample data from the design',
      (WidgetTester tester) async {
    await pumpDashboard(tester, const Size(393, 852));

    expect(find.text('Hello, Renz! 👋'), findsOneWidget);
    expect(find.text('Remaining Balance'), findsOneWidget);
    expect(find.text('₱ 850.00'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
    expect(find.text('Weekly Budget: ₱ 1,000.00'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('₱1,000.00'), findsOneWidget);
    expect(find.text('Spent'), findsOneWidget);
    expect(find.text('₱150.00'), findsOneWidget);
    expect(find.text('Spending by Category'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('View Details'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
  });

  testWidgets('Dashboard does not overflow on a small phone',
      (WidgetTester tester) async {
    await pumpDashboard(tester, const Size(320, 568));
    // flutter_test fails the test by itself if a layout overflow happens.
    expect(find.text('Remaining Balance'), findsOneWidget);
  });

  testWidgets('Dashboard does not overflow on a wide web window',
      (WidgetTester tester) async {
    await pumpDashboard(tester, const Size(1280, 800));
    expect(find.text('Remaining Balance'), findsOneWidget);
  });
}
