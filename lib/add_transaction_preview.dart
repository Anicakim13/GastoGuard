import 'package:flutter/material.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/theme/app_theme.dart';

/// TEMPORARY helper for previewing the Add Transaction screen on its own.
///
/// Navigation is not built yet, so use this file to see the screen:
///
///   flutter run -d edge -t lib/add_transaction_preview.dart
///
/// Delete this file once the screens are connected with navigation.
void main() {
  runApp(
    MaterialApp(
      title: 'GastoGuard - Add Transaction preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AddTransactionScreen(),
    ),
  );
}
