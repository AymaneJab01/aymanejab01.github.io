import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Thin singleton wrapper around the local SQLite database.
///
/// On Web, sqflite_common_ffi_web stores the database in browser storage.
/// On Android/iOS, the normal sqflite database factory is used.
/// On Windows/Linux/macOS, SQLite is provided through FFI.
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
    // ------------------------------------------------------------
    // WEB
    // ------------------------------------------------------------
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;

      return openDatabase(
        'fintrack.db',
        version: 1,
        onCreate: _createTables,
      );
    }

    // ------------------------------------------------------------
    // DESKTOP
    // ------------------------------------------------------------
    //
    // We cannot import dart:io here because Flutter Web cannot
    // compile code that depends on it.
    //
    // Desktop initialization is handled by sqflite_common_ffi
    // when the application runs outside Web.
    //
    // ------------------------------------------------------------

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

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
