import 'package:flutter/foundation.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/models/transaction_entry.dart';
import 'package:gastoguard/services/demo_transactions.dart';

/// The one list of transactions shared by the whole app.
///
/// It only lives in memory: when the app is closed, everything is forgotten.
/// (A database will replace this in a later phase.)
///
/// It is a [ChangeNotifier]: every time a transaction is added it
/// "notifies" the screens that are showing the list, and they redraw
/// themselves. That is how a new transaction appears in History by itself.
class TransactionStore extends ChangeNotifier {
  /// Creates a store, optionally starting with some [initial] transactions.
  TransactionStore({List<TransactionEntry> initial = const []})
      : _transactions = List.of(initial);

  /// Creates a store that starts with the sample transactions, so History is
  /// not empty while the app has no database yet.
  TransactionStore.withDemoData(DateTime today)
      : this(initial: buildDemoTransactions(today));

  final List<TransactionEntry> _transactions;
  int _nextId = 1;

  /// All transactions. This list cannot be changed directly; use
  /// [addTransaction] so that the screens are told about the change.
  List<TransactionEntry> get transactions => List.unmodifiable(_transactions);

  /// Adds a new transaction and tells the screens.
  /// Returns the transaction that was created.
  TransactionEntry addTransaction({
    required TransactionCategory category,
    required double amount,
    required bool isExpense,
    required DateTime dateTime,
    String? note,
  }) {
    final entry = TransactionEntry(
      id: 'user-${_nextId++}',
      category: category,
      amount: amount,
      isExpense: isExpense,
      dateTime: dateTime,
      note: note,
    );
    _transactions.add(entry);
    notifyListeners();
    return entry;
  }
}
