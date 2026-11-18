import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/models/transaction_entry.dart';
import 'package:gastoguard/services/transaction_store.dart';
import 'package:gastoguard/utils/amount_parser.dart';

void main() {
  group('TransactionStore', () {
    test('starts empty and keeps what is added', () {
      final store = TransactionStore();
      expect(store.transactions, isEmpty);

      final saved = store.addTransaction(
        category: TransactionCategory.food,
        amount: 75.5,
        isExpense: true,
        dateTime: DateTime(2026, 11, 9, 15, 45),
        note: 'Lunch',
      );

      expect(store.transactions.length, 1);
      expect(store.transactions.single, same(saved));
      expect(saved.category, TransactionCategory.food);
      expect(saved.amount, 75.5);
      expect(saved.isExpense, isTrue);
      expect(saved.dateTime, DateTime(2026, 11, 9, 15, 45));
      expect(saved.note, 'Lunch');
    });

    test('gives every new transaction its own id', () {
      final store = TransactionStore();
      TransactionEntry add() => store.addTransaction(
            category: TransactionCategory.data,
            amount: 10,
            isExpense: true,
            dateTime: DateTime(2026, 11, 9),
          );

      final first = add();
      final second = add();
      expect(first.id, isNot(second.id));
    });

    test('tells its listeners when a transaction is added', () {
      final store = TransactionStore();
      var calls = 0;
      store.addListener(() => calls++);

      store.addTransaction(
        category: TransactionCategory.others,
        amount: 500,
        isExpense: false,
        dateTime: DateTime(2026, 11, 1),
      );
      expect(calls, 1);
    });

    test('the list it hands out cannot be changed directly', () {
      final store = TransactionStore();
      final saved = store.addTransaction(
        category: TransactionCategory.food,
        amount: 1,
        isExpense: true,
        dateTime: DateTime(2026, 11, 9),
      );
      expect(() => store.transactions.add(saved), throwsUnsupportedError);
    });

    test('copies the starting list instead of sharing it', () {
      final start = <TransactionEntry>[
        TransactionEntry(
          id: 'a',
          category: TransactionCategory.food,
          amount: 5,
          isExpense: true,
          dateTime: DateTime(2026, 11, 9),
        ),
      ];
      final store = TransactionStore(initial: start);
      start.clear();
      expect(store.transactions.length, 1);
    });

    test('withDemoData starts with the 14 sample transactions', () {
      final store = TransactionStore.withDemoData(DateTime(2026, 11, 15));
      expect(store.transactions.length, 14);
    });
  });

  group('parseAmount', () {
    test('reads normal and unfinished numbers', () {
      expect(parseAmount('75.50'), 75.5);
      expect(parseAmount('.5'), 0.5);
      expect(parseAmount('12.'), 12.0);
      expect(parseAmount(' 7 '), 7.0);
      expect(parseAmount('0'), 0.0);
    });

    test('returns null when there is no number', () {
      expect(parseAmount(''), isNull);
      expect(parseAmount('   '), isNull);
      expect(parseAmount('abc'), isNull);
    });
  });
}
