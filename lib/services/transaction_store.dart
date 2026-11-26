
import 'package:flutter/foundation.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/models/transaction_entry.dart';
import 'package:gastoguard/services/app_database.dart';
import 'package:gastoguard/services/demo_transactions.dart';

class TransactionStore extends ChangeNotifier {
  TransactionStore({
    List<TransactionEntry> initial = const [],
    this.persistToDatabase = false,
  }) : _transactions = List.of(initial);

  TransactionStore.withDemoData(DateTime today)
      : this(initial: buildDemoTransactions(today));

  final List<TransactionEntry> _transactions;

  /// True only for the real app's SQLite-backed store.
  final bool persistToDatabase;

  int _nextId = 1;

  List<TransactionEntry> get transactions =>
      List.unmodifiable(_transactions);

  Future<void> loadTransactions() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'transactions',
      orderBy: 'dateTime DESC',
    );

    _transactions
      ..clear()
      ..addAll(
        rows.map(
          (row) => TransactionEntry(
            id: row['id'] as String,
            category: TransactionCategory.all.firstWhere(
              (category) => category.name == row['category'],
            ),
            amount: (row['amount'] as num).toDouble(),
            isExpense: (row['isExpense'] as int) == 1,
            dateTime: DateTime.parse(row['dateTime'] as String),
            note: row['note'] as String?,
          ),
        ),
      );

    notifyListeners();
  }

  TransactionEntry addTransaction({
    required TransactionCategory category,
    required double amount,
    required bool isExpense,
    required DateTime dateTime,
    String? note,
  }) {
    final entry = TransactionEntry(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}-${_nextId++}',
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

  Future<TransactionEntry> addTransactionAndSave({
    required TransactionCategory category,
    required double amount,
    required bool isExpense,
    required DateTime dateTime,
    String? note,
  }) async {
    if (!persistToDatabase) {
      return addTransaction(
        category: category,
        amount: amount,
        isExpense: isExpense,
        dateTime: dateTime,
        note: note,
      );
    }

    final entry = addTransaction(
      category: category,
      amount: amount,
      isExpense: isExpense,
      dateTime: dateTime,
      note: note,
    );

    try {
      final db = await AppDatabase.instance.database;
      await db.insert('transactions', {
        'id': entry.id,
        'category': entry.category.name,
        'amount': entry.amount,
        'isExpense': entry.isExpense ? 1 : 0,
        'dateTime': entry.dateTime.toIso8601String(),
        'note': entry.note,
      });
    } catch (_) {
      _transactions.remove(entry);
      notifyListeners();
      rethrow;
    }

    return entry;
  }

  /// Updates an existing transaction in memory.
  void updateTransaction({
    required String id,
    required TransactionCategory category,
    required double amount,
    required bool isExpense,
    required DateTime dateTime,
    String? note,
  }) {
    final index = _transactions.indexWhere((item) => item.id == id);

    if (index == -1) {
      throw StateError('Transaction not found');
    }

    _transactions[index] = TransactionEntry(
      id: id,
      category: category,
      amount: amount,
      isExpense: isExpense,
      dateTime: dateTime,
      note: note,
    );

    notifyListeners();
  }

  /// Updates an existing transaction and saves it to SQLite.
  Future<void> updateTransactionAndSave({
    required String id,
    required TransactionCategory category,
    required double amount,
    required bool isExpense,
    required DateTime dateTime,
    String? note,
  }) async {
    if (!persistToDatabase) {
      updateTransaction(
        id: id,
        category: category,
        amount: amount,
        isExpense: isExpense,
        dateTime: dateTime,
        note: note,
      );
      return;
    }

    final index = _transactions.indexWhere((item) => item.id == id);

    if (index == -1) {
      throw StateError('Transaction not found');
    }

    final db = await AppDatabase.instance.database;

    final count = await db.update(
      'transactions',
      {
        'category': category.name,
        'amount': amount,
        'isExpense': isExpense ? 1 : 0,
        'dateTime': dateTime.toIso8601String(),
        'note': note,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (count == 0) {
      throw StateError('Transaction not found in database');
    }

    _transactions[index] = TransactionEntry(
      id: id,
      category: category,
      amount: amount,
      isExpense: isExpense,
      dateTime: dateTime,
      note: note,
    );

    notifyListeners();
  }

  /// Deletes an existing transaction from memory.
  void deleteTransaction(String id) {
    final index = _transactions.indexWhere((item) => item.id == id);

    if (index == -1) {
      throw StateError('Transaction not found');
    }

    _transactions.removeAt(index);
    notifyListeners();
  }

  /// Deletes an existing transaction from SQLite and memory.
  Future<void> deleteTransactionAndSave(String id) async {
    if (!persistToDatabase) {
      deleteTransaction(id);
      return;
    }

    final index = _transactions.indexWhere((item) => item.id == id);

    if (index == -1) {
      throw StateError('Transaction not found');
    }

    final db = await AppDatabase.instance.database;

    final count = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (count == 0) {
      throw StateError('Transaction not found in database');
    }

    _transactions.removeAt(index);
    notifyListeners();
  }


  /// Deletes all transactions from SQLite and memory.
  /// Budget settings and profile settings are not affected.
  Future<void> deleteAllTransactionsAndSave() async {
    if (persistToDatabase) {
      final db = await AppDatabase.instance.database;

      await db.transaction((txn) async {
        await txn.delete('transactions');
      });
    }

    _transactions.clear();
    notifyListeners();
  }

}
