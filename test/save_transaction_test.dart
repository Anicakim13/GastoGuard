import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/services/transaction_store.dart';
import 'package:gastoguard/theme/app_theme.dart';
import 'package:gastoguard/widgets/category_card.dart';
import 'package:gastoguard/widgets/pill_toggle.dart';

void main() {
  // Pretend to be a typical phone (393 x 852 logical pixels).
  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // The Add Transaction screen with a fixed date (Nov 9) and a fixed clock
  // (3:45 PM), sharing [store] like the real app does.
  Future<void> pumpAddScreen(WidgetTester tester, TransactionStore store) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      TransactionScope(
        store: store,
        child: MaterialApp(
          theme: AppTheme.light,
          home: AddTransactionScreen(
            initialDate: DateTime(2026, 11, 9),
            currentTime: () => DateTime(2026, 11, 15, 15, 45),
          ),
        ),
      ),
    );
  }

  final amountField = find.byType(TextField).first;
  final noteField = find.byType(TextField).last;

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.text('Save Transaction'));
    await tester.pump();
  }

  testWidgets('Saving an expense adds it to the store',
      (WidgetTester tester) async {
    final store = TransactionStore();
    await pumpAddScreen(tester, store);

    await tester.enterText(amountField, '75.50');
    await tester.tap(find.text('Food'));
    await tester.pump();
    await tapSave(tester);

    expect(store.transactions.length, 1);
    final saved = store.transactions.single;
    expect(saved.category, TransactionCategory.food);
    expect(saved.amount, 75.5);
    expect(saved.isExpense, isTrue);
    // The date comes from the Date field, the time from the clock.
    expect(saved.dateTime, DateTime(2026, 11, 9, 15, 45));
    expect(saved.note, isNull);
    expect(find.text('Transaction saved'), findsOneWidget);
  });

  testWidgets('Saving income adds it as income', (WidgetTester tester) async {
    final store = TransactionStore();
    await pumpAddScreen(tester, store);

    await tester.tap(find.text('Income'));
    await tester.pump();
    await tester.enterText(amountField, '1000');
    await tester.tap(find.text('Others'));
    await tester.pump();
    await tapSave(tester);

    final saved = store.transactions.single;
    expect(saved.isExpense, isFalse);
    expect(saved.amount, 1000);
    expect(saved.category, TransactionCategory.others);
  });

  testWidgets('The note is saved without extra spaces',
      (WidgetTester tester) async {
    final store = TransactionStore();
    await pumpAddScreen(tester, store);

    await tester.enterText(amountField, '20');
    await tester.enterText(noteField, '  Lunch at school  ');
    await tester.tap(find.text('Data'));
    await tester.pump();
    await tapSave(tester);

    expect(store.transactions.single.note, 'Lunch at school');
  });

  testWidgets('The form is emptied after saving', (WidgetTester tester) async {
    final store = TransactionStore();
    await pumpAddScreen(tester, store);

    await tester.tap(find.text('Income'));
    await tester.pump();
    await tester.enterText(amountField, '40');
    await tester.tap(find.text('Food'));
    await tester.pump();
    await tapSave(tester);

    expect(tester.widget<TextField>(amountField).controller!.text, '');
    expect(tester.widget<TextField>(noteField).controller!.text, '');
    expect(tester.widget<PillToggle>(find.byType(PillToggle)).selectedIndex, 0);
    expect(
      tester
          .widget<CategoryCard>(find.widgetWithText(CategoryCard, 'Food'))
          .selected,
      isFalse,
    );
  });

  testWidgets('An empty or zero amount is not saved',
      (WidgetTester tester) async {
    final store = TransactionStore();
    await pumpAddScreen(tester, store);

    await tester.tap(find.text('Food'));
    await tester.pump();

    await tapSave(tester);
    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
    expect(store.transactions, isEmpty);

    await tester.enterText(amountField, '0');
    await tapSave(tester);
    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
    expect(store.transactions, isEmpty);
  });

  testWidgets('A transaction without a category is not saved',
      (WidgetTester tester) async {
    final store = TransactionStore();
    await pumpAddScreen(tester, store);

    await tester.enterText(amountField, '50');
    await tapSave(tester);

    expect(find.text('Choose a category'), findsOneWidget);
    expect(store.transactions, isEmpty);
  });

  testWidgets('Saving still works (without crashing) with no shared store',
      (WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AddTransactionScreen(initialDate: DateTime(2026, 11, 9)),
      ),
    );

    await tester.enterText(amountField, '30');
    await tester.tap(find.text('Food'));
    await tester.pump();
    await tapSave(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Transaction saved'), findsOneWidget);
  });
}
