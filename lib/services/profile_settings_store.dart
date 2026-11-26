
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gastoguard/services/app_database.dart';

class ProfileSettingsStore extends ChangeNotifier {
  ProfileSettingsStore({
    this.persistToDatabase = false,
  });

  final bool persistToDatabase;

  String _displayName = 'User';

  String get displayName => _displayName;

  Future<void> loadProfile() async {
    if (!persistToDatabase) return;

    final db = await AppDatabase.instance.database;

    final rows = await db.query(
      'profile_settings',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) return;

    _displayName = rows.first['displayName'] as String;
    notifyListeners();
  }

  Future<void> saveDisplayName(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Display name cannot be empty.');
    }

    if (trimmedName.length > 30) {
      throw ArgumentError('Display name cannot exceed 30 characters.');
    }

    if (persistToDatabase) {
      final db = await AppDatabase.instance.database;

      await db.insert(
        'profile_settings',
        {
          'id': 1,
          'displayName': trimmedName,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    _displayName = trimmedName;
    notifyListeners();
  }
}
