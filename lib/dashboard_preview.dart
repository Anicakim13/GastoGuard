import 'package:flutter/material.dart';
import 'package:gastoguard/screens/dashboard_screen.dart';
import 'package:gastoguard/theme/app_theme.dart';

/// TEMPORARY helper for previewing the Dashboard on its own.
///
/// The Splash Screen's GET STARTED button is not connected yet, so use this
/// file to see the Dashboard without touching main.dart:
///
///   flutter run -d edge -t lib/dashboard_preview.dart
///
/// Delete this file once the screens are connected with navigation.
void main() {
  runApp(
    MaterialApp(
      title: 'GastoGuard - Dashboard preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const DashboardScreen(),
    ),
  );
}
