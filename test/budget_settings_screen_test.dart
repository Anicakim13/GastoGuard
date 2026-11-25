import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/screens/budget_settings_screen.dart';
import 'package:gastoguard/screens/history_screen.dart';
import 'package:gastoguard/screens/spending_summary_screen.dart';
import 'package:gastoguard/theme/app_theme.dart';
import 'package:gastoguard/widgets/app_bottom_nav.dart';
import 'package:gastoguard/widgets/pill_toggle.dart';

void main() {
  void usePhoneScreen(WidgetTester tester, Size logicalSize) {
    tester.view.physicalSize = logicalSize * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // The screen on its own, with a weekly budget of 1,000 and a monthly budget
  // of 4,000 (so the tests do not depend on the app's sample values).
  Future<void> pumpBudget(
    WidgetTester tester, {
    Size size = const Size(393, 852),
  }) async {
    usePhoneScreen(tester, size);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const BudgetSettingsScreen(
          initialWeeklyLimit: 1000,
          initialMonthlyLimit: 4000,
        ),
      ),
    );
  }

  // The screen opened from another screen (an "Open" button), like it will be
  // opened from the rest of the app later. It lets us test going back.
  Future<void> pumpOpenedFromAnotherScreen(WidgetTester tester) async {
    usePhoneScreen(tester, const Size(393, 852));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const BudgetSettingsScreen(),
                  ),
                ),
                child: const Text('Open budget settings'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open budget settings'));
    await tester.pumpAndSettle();
  }

  final amountField = find.byType(TextField);

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(amountField).controller!.text;

  bool switchValue(WidgetTester tester, int index) =>
      tester.widget<Switch>(find.byType(Switch).at(index)).value;

  // Moves the cursor out of the amount field, like tapping somewhere else.
  Future<void> leaveField(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
  }

  testWidgets('Budget Settings shows every part of the design',
      (WidgetTester tester) async {
    await pumpBudget(tester);

    expect(find.text('Budget Settings'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Set Budget Limit'), findsOneWidget);
    expect(find.text('₱'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    // Monthly is selected at first, like the Canva design.
    expect(tester.widget<PillToggle>(find.byType(PillToggle)).selectedIndex, 1);
    expect(fieldText(tester), '4,000.00');

    // Two alerts, both switched on.
    expect(find.text('Notify at 80% (₱3,200.00)'), findsOneWidget);
    expect(find.text('Notify at 100% (₱4,000.00)'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(2));
    expect(switchValue(tester, 0), isTrue);
    expect(switchValue(tester, 1), isTrue);

    // The bottom bar, with Summary highlighted like in the design.
    final nav = tester.widget<AppBottomNav>(find.byType(AppBottomNav));
    expect(nav.currentIndex, AppBottomNav.summaryIndex);
  });

  testWidgets('The Weekly and Monthly tabs show their own budget',
      (WidgetTester tester) async {
    await pumpBudget(tester);

    await tester.tap(find.text('Weekly'));
    await tester.pump();
    expect(tester.widget<PillToggle>(find.byType(PillToggle)).selectedIndex, 0);
    expect(fieldText(tester), '1,000.00');
    expect(find.text('Notify at 80% (₱800.00)'), findsOneWidget);
    expect(find.text('Notify at 100% (₱1,000.00)'), findsOneWidget);

    await tester.tap(find.text('Monthly'));
    await tester.pump();
    expect(fieldText(tester), '4,000.00');
    expect(find.text('Notify at 80% (₱3,200.00)'), findsOneWidget);
  });

  testWidgets('Typing a budget updates the alert amounts, and the field is '
      'tidied when you leave it', (WidgetTester tester) async {
    await pumpBudget(tester);

    await tester.enterText(amountField, '2500');
    await tester.pump();
    expect(find.text('Notify at 80% (₱2,000.00)'), findsOneWidget);
    expect(find.text('Notify at 100% (₱2,500.00)'), findsOneWidget);
    expect(fieldText(tester), '2500'); // plain while typing

    await leaveField(tester);
    expect(fieldText(tester), '2,500.00'); // tidy afterwards
  });

  testWidgets('Each period keeps its own typed budget',
      (WidgetTester tester) async {
    await pumpBudget(tester);

    await tester.enterText(amountField, '2500');
    await leaveField(tester);

    await tester.tap(find.text('Weekly'));
    await tester.pump();
    expect(fieldText(tester), '1,000.00'); // the weekly budget is untouched

    await tester.tap(find.text('Monthly'));
    await tester.pump();
    expect(fieldText(tester), '2,500.00'); // the edit was remembered
  });

  testWidgets('Only digits and up to two decimals can be typed',
      (WidgetTester tester) async {
    await pumpBudget(tester);

    await tester.enterText(amountField, '12.345');
    await tester.pump();
    expect(fieldText(tester), '12.34');
    expect(find.text('Notify at 80% (₱9.87)'), findsOneWidget);
    expect(find.text('Notify at 100% (₱12.34)'), findsOneWidget);

    await tester.enterText(amountField, 'abc');
    await tester.pump();
    expect(fieldText(tester), '');
    expect(find.text('Notify at 80% (₱0.00)'), findsOneWidget);
  });

  testWidgets('The alert switches can be switched on and off',
      (WidgetTester tester) async {
    await pumpBudget(tester);

    // Tapping the switch itself.
    await tester.tap(find.byType(Switch).at(0));
    await tester.pump();
    expect(switchValue(tester, 0), isFalse);
    expect(switchValue(tester, 1), isTrue);

    // Tapping the text of the row works too.
    await tester.tap(find.text('Notify at 100% (₱4,000.00)'));
    await tester.pump();
    expect(switchValue(tester, 1), isFalse);

    await tester.tap(find.text('Notify at 100% (₱4,000.00)'));
    await tester.pump();
    expect(switchValue(tester, 1), isTrue);
  });

  testWidgets('Save Changes confirms a valid budget',
      (WidgetTester tester) async {
    await pumpBudget(tester);

    await tester.tap(find.text('Save Changes'));
    await tester.pump();

    expect(find.text('Budget settings saved'), findsOneWidget);
  });

  testWidgets('Save Changes refuses an empty budget',
      (WidgetTester tester) async {
    await pumpBudget(tester);

    await tester.enterText(amountField, '');
    await tester.tap(find.text('Save Changes'));
    await tester.pump();

    expect(find.text('Enter a budget greater than zero'), findsOneWidget);
    expect(find.text('Budget settings saved'), findsNothing);
  });

  testWidgets('The back arrow returns to the screen before',
      (WidgetTester tester) async {
    await pumpOpenedFromAnotherScreen(tester);
    expect(find.byType(BudgetSettingsScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(BudgetSettingsScreen), findsNothing);
    expect(find.text('Open budget settings'), findsOneWidget);
  });

  testWidgets('The back arrow does nothing when it is the only screen',
      (WidgetTester tester) async {
    await pumpBudget(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(BudgetSettingsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home in the bottom bar returns to the first screen',
      (WidgetTester tester) async {
    await pumpOpenedFromAnotherScreen(tester);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.byType(BudgetSettingsScreen), findsNothing);
    expect(find.text('Open budget settings'), findsOneWidget);
  });

  testWidgets('Add in the bottom bar opens Add Transaction and back returns',
      (WidgetTester tester) async {
    await pumpOpenedFromAnotherScreen(tester);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionScreen), findsNothing);
    expect(find.byType(BudgetSettingsScreen), findsOneWidget);
  });

  testWidgets('History in the bottom bar swaps to the History screen',
      (WidgetTester tester) async {
    await pumpOpenedFromAnotherScreen(tester);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.byType(BudgetSettingsScreen), findsNothing);
  });

  testWidgets('Summary in the bottom bar swaps to the Spending Summary',
      (WidgetTester tester) async {
    await pumpOpenedFromAnotherScreen(tester);

    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    expect(find.byType(SpendingSummaryScreen), findsOneWidget);
    expect(find.byType(BudgetSettingsScreen), findsNothing);
  });

  testWidgets('Budget Settings does not overflow on a small phone',
      (WidgetTester tester) async {
    await pumpBudget(tester, size: const Size(320, 568));

    // A huge budget makes the alert texts long.
    await tester.enterText(amountField, '9999999.99');
    await tester.pump();

    // flutter_test fails the test by itself if a layout overflow happens.
    expect(find.text('Notify at 100% (₱9,999,999.99)'), findsOneWidget);
  });

  testWidgets('Budget Settings does not overflow on a wide web window',
      (WidgetTester tester) async {
    await pumpBudget(tester, size: const Size(1280, 800));
    expect(find.text('Budget Settings'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });
}
