import 'package:flutter/material.dart';
import 'package:gastoguard/screens/history_screen.dart';
import 'package:gastoguard/theme/app_theme.dart';

/// TEMPORARY helper for previewing the History screen on its own:
///
///   flutter run -d edge -t lib/history_preview.dart
///
/// (In the full app, open it from the History item in the bottom bar.)
void main() {
  runApp(
    MaterialApp(
      title: 'GastoGuard - History preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HistoryScreen(),
    ),
  );
}
