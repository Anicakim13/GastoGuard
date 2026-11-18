import 'package:flutter/widgets.dart';
import 'package:gastoguard/services/transaction_store.dart';

/// Makes one [TransactionStore] available to every screen below it.
///
/// It is placed at the top of the app (in main.dart), so the Add Transaction
/// and History screens both use the same list.
///
/// In a screen's build method:
///   final store = TransactionScope.maybeOf(context);
/// The screen then redraws whenever the store changes.
class TransactionScope extends InheritedNotifier<TransactionStore> {
  const TransactionScope({
    super.key,
    required TransactionStore store,
    required super.child,
  }) : super(notifier: store);

  /// Finds the store, and makes the calling widget redraw when it changes.
  /// Use this inside build methods. Returns null if there is no scope.
  static TransactionStore? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TransactionScope>()
        ?.notifier;
  }

  /// Finds the store WITHOUT redrawing when it changes.
  /// Use this inside button handlers. Returns null if there is no scope.
  static TransactionStore? maybeRead(BuildContext context) {
    return context.getInheritedWidgetOfExactType<TransactionScope>()?.notifier;
  }
}
