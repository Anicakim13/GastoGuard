import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/theme/app_theme.dart';
import 'package:gastoguard/widgets/category_card.dart';
import 'package:gastoguard/widgets/pill_toggle.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester, Size logicalSize) async {
    tester.view.physicalSize = logicalSize * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        // A fixed date keeps the test results the same every day.
        home: AddTransactionScreen(initialDate: DateTime(2026, 11, 9)),
      ),
    );
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
    expect(find.text('Nov 09, 2026'), findsOneWidget);
    expect(find.text('Note (Optional)'), findsOneWidget);
    expect(find.text('Save Transaction'), findsOneWidget);
  });

  testWidgets('Toggle and category cards change their selection',
      (WidgetTester tester) async {
    await pumpScreen(tester, const Size(393, 852));

    // Expense is selected at first, and no category is selected.
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

    // The Amount field is the first text field on the screen.
    await tester.enterText(find.byType(TextField).first, '12.345');
    await tester.pump();
    expect(find.text('12.34'), findsOneWidget);
  });

  testWidgets('Add Transaction does not overflow on a small phone',
      (WidgetTester tester) async {
    await pumpScreen(tester, const Size(320, 568));
    // flutter_test fails the test by itself if a layout overflow happens.
    expect(find.text('Save Transaction'), findsOneWidget);
  });

  testWidgets('Add Transaction does not overflow on a wide web window',
      (WidgetTester tester) async {
    await pumpScreen(tester, const Size(1280, 800));
    expect(find.text('Save Transaction'), findsOneWidget);
  });
}
