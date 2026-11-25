
import 'package:flutter/material.dart';
import 'package:gastoguard/screens/splash_screen.dart';
import 'package:gastoguard/services/budget_settings_scope.dart';
import 'package:gastoguard/services/budget_settings_store.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/services/transaction_store.dart';
import 'package:gastoguard/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    GastoGuardApp(
      store: TransactionStore(persistToDatabase: true),
    ),
  );
}

class GastoGuardApp extends StatefulWidget {
  const GastoGuardApp({super.key, this.store});

  final TransactionStore? store;

  @override
  State<GastoGuardApp> createState() => _GastoGuardAppState();
}

class _GastoGuardAppState extends State<GastoGuardApp> {
  late final TransactionStore _store;
  late final BudgetSettingsStore _budgetStore;

  bool _isReady = false;
  Object? _initializationError;

  @override
  void initState() {
    super.initState();

    _store = widget.store ??
        TransactionStore.withDemoData(DateTime.now());

    _budgetStore = BudgetSettingsStore(
      persistToDatabase: _store.persistToDatabase,
    );

    if (_store.persistToDatabase) {
      _initializeApp();
    } else {
      _isReady = true;
    }
  }

  Future<void> _initializeApp() async {
    try {
      await _store.loadTransactions();
      await _budgetStore.loadSettings();
    } catch (error) {
      _initializationError = error;
    }

    if (!mounted) return;

    setState(() {
      _isReady = true;
    });
  }

  @override
  void dispose() {
    _store.dispose();
    _budgetStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_initializationError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load app data. '
                'Please restart the app.\n\n$_initializationError',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return TransactionScope(
      store: _store,
      child: BudgetSettingsScope(
        store: _budgetStore,
        child: MaterialApp(
          title: 'GastoGuard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
