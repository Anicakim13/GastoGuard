import 'package:flutter/material.dart';
import 'package:gastoguard/screens/spending_summary_screen.dart';
import 'package:gastoguard/theme/app_theme.dart';

/// TEMPORARY helper for previewing the Spending Summary screen on its own:
///
///   flutter run -d edge -t lib/spending_summary_preview.dart
///
/// (In the full app, open it from the Summary item in the bottom bar or the
/// "View Details" button on the Dashboard.)
void main() {
  runApp(
    MaterialApp(
      title: 'GastoGuard - Spending Summary preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SpendingSummaryScreen(),
    ),
  );
}
