import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../models/user_model.dart';

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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // icon_name TEXT em vez de icon_code INTEGER — evita problemas com codepoints
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        type TEXT NOT NULL
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

    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final categories = [
      // Despesas
      {'name': 'Alimentação',  'icon_name': 'restaurant',      'color_value': 0xFFFF9800, 'type': 'expense'},
      {'name': 'Transporte',   'icon_name': 'directions_car',  'color_value': 0xFF2196F3, 'type': 'expense'},
      {'name': 'Moradia',      'icon_name': 'home',            'color_value': 0xFF795548, 'type': 'expense'},
      {'name': 'Saúde',        'icon_name': 'local_hospital',  'color_value': 0xFFE91E63, 'type': 'expense'},
      {'name': 'Lazer',        'icon_name': 'sports_esports',  'color_value': 0xFF9C27B0, 'type': 'expense'},
      {'name': 'Educação',     'icon_name': 'school',          'color_value': 0xFF3F51B5, 'type': 'expense'},
      {'name': 'Roupas',       'icon_name': 'shopping_bag',    'color_value': 0xFFE91E63, 'type': 'expense'},
      {'name': 'Outros',       'icon_name': 'more_horiz',      'color_value': 0xFF607D8B, 'type': 'expense'},
      // Receitas
      {'name': 'Salário',      'icon_name': 'work',            'color_value': 0xFF4CAF50, 'type': 'income'},
      {'name': 'Freelance',    'icon_name': 'computer',        'color_value': 0xFF00BCD4, 'type': 'income'},
      {'name': 'Investimentos','icon_name': 'trending_up',     'color_value': 0xFF4CAF50, 'type': 'income'},
      {'name': 'Presente',     'icon_name': 'card_giftcard',   'color_value': 0xFF9C27B0, 'type': 'income'},
      {'name': 'Outros',       'icon_name': 'more_horiz',      'color_value': 0xFF607D8B, 'type': 'income'},
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
