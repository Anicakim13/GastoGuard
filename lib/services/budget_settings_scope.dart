
import 'package:flutter/widgets.dart';
import 'package:gastoguard/services/budget_settings_store.dart';

class BudgetSettingsScope extends InheritedNotifier<BudgetSettingsStore> {
  const BudgetSettingsScope({
    super.key,
    required BudgetSettingsStore store,
    required super.child,
  }) : super(notifier: store);

  static BudgetSettingsStore? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<BudgetSettingsScope>()
        ?.notifier;
  }

  static BudgetSettingsStore? maybeRead(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<BudgetSettingsScope>()
        ?.notifier;
  }
}
