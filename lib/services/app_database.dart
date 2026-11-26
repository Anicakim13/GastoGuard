
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _databaseName = 'gastoguard.db';
  static const int _databaseVersion = 3;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            isExpense INTEGER NOT NULL,
            dateTime TEXT NOT NULL,
            note TEXT
          )
        ''');

        await _createBudgetSettingsTable(db);
        await _createProfileSettingsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createBudgetSettingsTable(db);
        }

        if (oldVersion < 3) {
          await _createProfileSettingsTable(db);
        }
      },
    );

    return _database!;
  }

  Future<void> _createBudgetSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE budget_settings (
        id INTEGER PRIMARY KEY,
        weeklyLimit REAL NOT NULL DEFAULT 1000,
        monthlyLimit REAL NOT NULL DEFAULT 4000,
        alert80Enabled INTEGER NOT NULL DEFAULT 1,
        alert100Enabled INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.insert('budget_settings', {
      'id': 1,
      'weeklyLimit': 1000.0,
      'monthlyLimit': 4000.0,
      'alert80Enabled': 1,
      'alert100Enabled': 1,
    });
  }

  Future<void> _createProfileSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE profile_settings (
        id INTEGER PRIMARY KEY,
        displayName TEXT NOT NULL DEFAULT 'User'
      )
    ''');

    await db.insert('profile_settings', {
      'id': 1,
      'displayName': 'User',
    });
  }
}
