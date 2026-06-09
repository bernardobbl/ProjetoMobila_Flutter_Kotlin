import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../models/user_model.dart';
import '../../models/budget_model.dart';
import '../../models/recurring_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final path = kIsWeb
        ? 'finanflow_v3.db'
        : join(await getDatabasesPath(), 'finanflow_v3.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        salt TEXT,
        photo_path TEXT
      )
    ''');

    // icon_name TEXT em vez de icon_code INTEGER — evita problemas com codepoints
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        type TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await _createBudgetsTable(db);
    await _createRecurringTable(db);
    await _insertDefaultCategories(db);
  }

  /// Migração para usuários que já tinham o app numa versão anterior do banco.
  /// Mantém todos os dados existentes, apenas adiciona o que é novo.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN salt TEXT');
      await db.execute(
          'ALTER TABLE categories ADD COLUMN is_default INTEGER NOT NULL DEFAULT 1');
      await _createBudgetsTable(db);
      await _createRecurringTable(db);
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE users ADD COLUMN photo_path TEXT');
    }
  }

  Future<void> _createBudgetsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS budgets (
        user_id INTEGER PRIMARY KEY,
        amount REAL NOT NULL
      )
    ''');
  }

  Future<void> _createRecurringTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS recurring_transactions (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        day_of_month INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        last_generated TEXT
      )
    ''');
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final categories = [
      // Despesas
      {'name': 'Alimentação',  'icon_name': 'restaurant',      'color_value': 0xFFFF9800, 'type': 'expense', 'is_default': 1},
      {'name': 'Transporte',   'icon_name': 'directions_car',  'color_value': 0xFF2196F3, 'type': 'expense', 'is_default': 1},
      {'name': 'Moradia',      'icon_name': 'home',            'color_value': 0xFF795548, 'type': 'expense', 'is_default': 1},
      {'name': 'Saúde',        'icon_name': 'local_hospital',  'color_value': 0xFFE91E63, 'type': 'expense', 'is_default': 1},
      {'name': 'Lazer',        'icon_name': 'sports_esports',  'color_value': 0xFF9C27B0, 'type': 'expense', 'is_default': 1},
      {'name': 'Educação',     'icon_name': 'school',          'color_value': 0xFF3F51B5, 'type': 'expense', 'is_default': 1},
      {'name': 'Roupas',       'icon_name': 'shopping_bag',    'color_value': 0xFFE91E63, 'type': 'expense', 'is_default': 1},
      {'name': 'Outros',       'icon_name': 'more_horiz',      'color_value': 0xFF607D8B, 'type': 'expense', 'is_default': 1},
      // Receitas
      {'name': 'Salário',      'icon_name': 'work',            'color_value': 0xFF4CAF50, 'type': 'income', 'is_default': 1},
      {'name': 'Freelance',    'icon_name': 'computer',        'color_value': 0xFF00BCD4, 'type': 'income', 'is_default': 1},
      {'name': 'Investimentos','icon_name': 'trending_up',     'color_value': 0xFF4CAF50, 'type': 'income', 'is_default': 1},
      {'name': 'Presente',     'icon_name': 'card_giftcard',   'color_value': 0xFF9C27B0, 'type': 'income', 'is_default': 1},
      {'name': 'Outros',       'icon_name': 'more_horiz',      'color_value': 0xFF607D8B, 'type': 'income', 'is_default': 1},
    ];

    for (final cat in categories) {
      await db.insert('categories', cat);
    }
  }

  // ─── Users ────────────────────────────────────────────────────────────

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return db.insert('users', user.toMap());
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  // ─── Categories ───────────────────────────────────────────────────────

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await database;
    final result = await db.query('categories', orderBy: 'type DESC, name ASC');
    return result.map(CategoryModel.fromMap).toList();
  }

  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    final db = await database;
    final result = await db.query('categories', where: 'type = ?', whereArgs: [type]);
    return result.map(CategoryModel.fromMap).toList();
  }

  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return db.insert('categories', category.toMap());
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return db.update('categories', category.toMap(),
        where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  /// Quantas transações usam esta categoria (para impedir exclusão em uso).
  Future<int> countTransactionsForCategory(int categoryId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM transactions WHERE category_id = ?',
      [categoryId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─── Budget (orçamento mensal) ────────────────────────────────────────

  Future<BudgetModel?> getBudget(int userId) async {
    final db = await database;
    final result =
        await db.query('budgets', where: 'user_id = ?', whereArgs: [userId]);
    if (result.isEmpty) return null;
    return BudgetModel.fromMap(result.first);
  }

  Future<void> setBudget(BudgetModel budget) async {
    final db = await database;
    await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBudget(int userId) async {
    final db = await database;
    await db.delete('budgets', where: 'user_id = ?', whereArgs: [userId]);
  }

  // ─── Recurring (transações recorrentes) ───────────────────────────────

  Future<List<RecurringModel>> getRecurringByUser(int userId) async {
    final db = await database;
    final result = await db.query(
      'recurring_transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'day_of_month ASC',
    );
    return result.map(RecurringModel.fromMap).toList();
  }

  Future<void> insertRecurring(RecurringModel rule) async {
    final db = await database;
    await db.insert('recurring_transactions', rule.toMap());
  }

  Future<void> updateRecurring(RecurringModel rule) async {
    final db = await database;
    await db.update('recurring_transactions', rule.toMap(),
        where: 'id = ?', whereArgs: [rule.id]);
  }

  Future<void> deleteRecurring(String id) async {
    final db = await database;
    await db.delete('recurring_transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Transactions ─────────────────────────────────────────────────────

  Future<String> insertTransaction(TransactionModel tx) async {
    final db = await database;
    await db.insert('transactions', tx.toMap());
    return tx.id;
  }

  Future<int> updateTransaction(TransactionModel tx) async {
    final db = await database;
    return db.update('transactions', tx.toMap(), where: 'id = ?', whereArgs: [tx.id]);
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TransactionModel>> getTransactionsByUser(int userId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return result.map(TransactionModel.fromMap).toList();
  }
}
