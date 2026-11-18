import 'package:flutter/material.dart';
import 'package:gastoguard/screens/splash_screen.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/services/transaction_store.dart';
import 'package:gastoguard/theme/app_theme.dart';

void main() {
  runApp(const GastoGuardApp());
}

/// The root of the app: sets the title, the theme, and the first screen.
/// It also owns the list of transactions that all screens share.
class GastoGuardApp extends StatefulWidget {
  const GastoGuardApp({super.key});

  @override
  State<GastoGuardApp> createState() => _GastoGuardAppState();
}

class _GastoGuardAppState extends State<GastoGuardApp> {
  // The one list of transactions, kept in memory only (no database yet).
  // It starts with the sample transactions so History is not empty.
  final TransactionStore _store = TransactionStore.withDemoData(DateTime.now());

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TransactionScope sits above MaterialApp, so every screen can reach the
    // same store.
    return TransactionScope(
      store: _store,
      child: MaterialApp(
        title: 'GastoGuard',
        debugShowCheckedModeBanner: false, // hides the red DEBUG ribbon
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
