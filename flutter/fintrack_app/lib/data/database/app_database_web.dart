import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Local SQLite database implementation for Flutter Web.
///
/// sqflite_common_ffi_web stores the SQLite database in
/// browser storage, using IndexedDB.
class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    // Flutter Web uses the browser-based database factory.
    databaseFactory = databaseFactoryFfiWeb;

    return openDatabase(
      'fintrack.db',
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        last4 TEXT NOT NULL,
        balance REAL NOT NULL,
        colorValue INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        isIncome INTEGER NOT NULL,
        date TEXT NOT NULL,
        accountId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        "limit" REAL NOT NULL,
        spent REAL NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target REAL NOT NULL,
        saved REAL NOT NULL DEFAULT 0,
        deadline TEXT
      )
    ''');
  }
}
