import 'package:gastoguard/models/transaction_category.dart';

/// One income or expense in the transaction history.
///
/// They are either demo values (services/demo_transactions.dart) or saved from
/// the Add Transaction screen. They are kept in memory for now (see
/// services/transaction_store.dart); a database comes later.
class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.category,
    required this.amount,
    required this.isExpense,
    required this.dateTime,
    this.note,
  });

  /// A unique id for this transaction.
  final String id;

  /// Which category it belongs to, for example Food.
  final TransactionCategory category;

  /// The amount in pesos. Always positive: [isExpense] says if it is money
  /// spent or money received.
  final double amount;

  /// true = money spent (shown in red), false = money received (income).
  final bool isExpense;

  /// When the transaction happened.
  final DateTime dateTime;

  /// The optional note typed on the Add Transaction screen (not shown yet).
  final String? note;
}
