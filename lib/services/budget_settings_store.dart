import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:gastoguard/services/app_database.dart';

class BudgetSettingsStore extends ChangeNotifier {
  BudgetSettingsStore({
    this.persistToDatabase = false,
  });

  final bool persistToDatabase;

  double _weeklyLimit = 1000;
  double _monthlyLimit = 4000;

  bool _alert80Enabled = true;
  bool _alert100Enabled = true;

  double get weeklyLimit => _weeklyLimit;
  double get monthlyLimit => _monthlyLimit;

  bool get alert80Enabled => _alert80Enabled;
  bool get alert100Enabled => _alert100Enabled;

  Future<void> loadSettings() async {
    if (!persistToDatabase) return;

    final db = await AppDatabase.instance.database;

    final rows = await db.query(
      'budget_settings',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) return;

    final row = rows.first;

    _weeklyLimit = (row['weeklyLimit'] as num).toDouble();
    _monthlyLimit = (row['monthlyLimit'] as num).toDouble();

    _alert80Enabled = row['alert80Enabled'] == 1;
    _alert100Enabled = row['alert100Enabled'] == 1;

    notifyListeners();
  }

  Future<void> saveSettings({
    required double weeklyLimit,
    required double monthlyLimit,
    required bool alert80Enabled,
    required bool alert100Enabled,
  }) async {
    if (weeklyLimit <= 0 || monthlyLimit <= 0) {
      throw ArgumentError('Budget limits must be greater than zero.');
    }

    if (persistToDatabase) {
      final db = await AppDatabase.instance.database;

      await db.insert(
        'budget_settings',
        {
          'id': 1,
          'weeklyLimit': weeklyLimit,
          'monthlyLimit': monthlyLimit,
          'alert80Enabled': alert80Enabled ? 1 : 0,
          'alert100Enabled': alert100Enabled ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    _weeklyLimit = weeklyLimit;
    _monthlyLimit = monthlyLimit;
    _alert80Enabled = alert80Enabled;
    _alert100Enabled = alert100Enabled;

    notifyListeners();
  }
}
