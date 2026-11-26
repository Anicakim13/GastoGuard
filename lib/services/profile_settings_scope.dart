
import 'package:flutter/widgets.dart';
import 'package:gastoguard/services/profile_settings_store.dart';

class ProfileSettingsScope
    extends InheritedNotifier<ProfileSettingsStore> {
  const ProfileSettingsScope({
    super.key,
    required ProfileSettingsStore store,
    required super.child,
  }) : super(notifier: store);

  static ProfileSettingsStore? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProfileSettingsScope>()
        ?.notifier;
  }

  static ProfileSettingsStore? maybeRead(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<ProfileSettingsScope>()
        ?.notifier;
  }
}
