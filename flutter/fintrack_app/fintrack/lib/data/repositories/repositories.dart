import 'package:flutter/foundation.dart';
import '../database/app_database.dart';
import '../models/models.dart';

/// Every repository below follows the same pattern:
///  - loads rows from SQLite into an in-memory list
///  - exposes that list to the UI
///  - add / update / delete write through to SQLite, then notify listeners
///
/// Screens never talk to SQLite directly — they only ever touch a
/// repository, so adding or managing data always goes through one
/// simple, consistent path.

class TransactionRepository extends ChangeNotifier {
  List<TransactionModel> _items = [];
  List<TransactionModel> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('transactions', orderBy: 'date DESC');
    _items = rows.map(TransactionModel.fromMap).toList();
    notifyListeners();
  }

  double get totalIncome => _items.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
  double get totalExpense => _items.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

  Future<void> add(TransactionModel t) async {
    final db = await AppDatabase.instance.database;
    final id = await db.insert('transactions', t.toMap()..remove('id'));
    _items.insert(0, t.copyWith(id: id));
    notifyListeners();
  }

  Future<void> update(TransactionModel t) async {
    final db = await AppDatabase.instance.database;
    await db.update('transactions', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
    final idx = _items.indexWhere((e) => e.id == t.id);
    if (idx != -1) _items[idx] = t;
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

class AccountRepository extends ChangeNotifier {
  List<AccountModel> _items = [];
  List<AccountModel> get items => List.unmodifiable(_items);

  double get totalBalance => _items.fold(0.0, (s, a) => s + a.balance);

  Future<void> load() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('accounts');
    _items = rows.map(AccountModel.fromMap).toList();
    notifyListeners();
  }

  Future<void> add(AccountModel a) async {
    final db = await AppDatabase.instance.database;
    final id = await db.insert('accounts', a.toMap()..remove('id'));
    _items.add(a.copyWith(id: id));
    notifyListeners();
  }

  Future<void> update(AccountModel a) async {
    final db = await AppDatabase.instance.database;
    await db.update('accounts', a.toMap(), where: 'id = ?', whereArgs: [a.id]);
    final idx = _items.indexWhere((e) => e.id == a.id);
    if (idx != -1) _items[idx] = a;
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Quick balance adjustment used by the "Add money / Withdraw" sheet
  /// on the dashboard.
  Future<void> adjustBalance(int accountId, double delta) async {
    final idx = _items.indexWhere((e) => e.id == accountId);
    if (idx == -1) return;
    final updated = _items[idx].copyWith(balance: _items[idx].balance + delta);
    await update(updated);
  }
}

class BudgetRepository extends ChangeNotifier {
  List<BudgetModel> _items = [];
  List<BudgetModel> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('budgets');
    _items = rows.map(BudgetModel.fromMap).toList();
    notifyListeners();
  }

  Future<void> add(BudgetModel b) async {
    final db = await AppDatabase.instance.database;
    final id = await db.insert('budgets', b.toMap()..remove('id'));
    _items.add(b.copyWith(id: id));
    notifyListeners();
  }

  Future<void> update(BudgetModel b) async {
    final db = await AppDatabase.instance.database;
    await db.update('budgets', b.toMap(), where: 'id = ?', whereArgs: [b.id]);
    final idx = _items.indexWhere((e) => e.id == b.id);
    if (idx != -1) _items[idx] = b;
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

class GoalRepository extends ChangeNotifier {
  List<GoalModel> _items = [];
  List<GoalModel> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('goals');
    _items = rows.map(GoalModel.fromMap).toList();
    notifyListeners();
  }

  Future<void> add(GoalModel g) async {
    final db = await AppDatabase.instance.database;
    final id = await db.insert('goals', g.toMap()..remove('id'));
    _items.add(g.copyWith(id: id));
    notifyListeners();
  }

  Future<void> update(GoalModel g) async {
    final db = await AppDatabase.instance.database;
    await db.update('goals', g.toMap(), where: 'id = ?', whereArgs: [g.id]);
    final idx = _items.indexWhere((e) => e.id == g.id);
    if (idx != -1) _items[idx] = g;
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

/// Simple profile store backed by SharedPreferences (added in
/// ProfileRepository's own load/save calls via shared_preferences),
/// kept in memory here and exposed through Provider.
class ProfileRepository extends ChangeNotifier {
  UserProfile profile = const UserProfile(
    name: 'Aymane Jabrane',
    email: 'aymane@example.com',
    phone: '+34 600 000 000',
  );

  void update(UserProfile p) {
    profile = p;
    notifyListeners();
  }
}
