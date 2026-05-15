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
    final path = join(await getDatabasesPath(), 'finanflow.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
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
      {'name': 'Alimentação', 'icon_code': 0xe25a, 'color_value': 0xFFFF9800, 'type': 'expense'},
      {'name': 'Transporte', 'icon_code': 0xe531, 'color_value': 0xFF2196F3, 'type': 'expense'},
      {'name': 'Moradia', 'icon_code': 0xe318, 'color_value': 0xFF795548, 'type': 'expense'},
      {'name': 'Saúde', 'icon_code': 0xe3f3, 'color_value': 0xFFE91E63, 'type': 'expense'},
      {'name': 'Lazer', 'icon_code': 0xe021, 'color_value': 0xFF9C27B0, 'type': 'expense'},
      {'name': 'Educação', 'icon_code': 0xe80c, 'color_value': 0xFF3F51B5, 'type': 'expense'},
      {'name': 'Roupas', 'icon_code': 0xe3b6, 'color_value': 0xFFE91E63, 'type': 'expense'},
      {'name': 'Outros', 'icon_code': 0xe5d3, 'color_value': 0xFF607D8B, 'type': 'expense'},
      // Receitas
      {'name': 'Salário', 'icon_code': 0xe943, 'color_value': 0xFF4CAF50, 'type': 'income'},
      {'name': 'Freelance', 'icon_code': 0xe30a, 'color_value': 0xFF00BCD4, 'type': 'income'},
      {'name': 'Investimentos', 'icon_code': 0xe6e1, 'color_value': 0xFF4CAF50, 'type': 'income'},
      {'name': 'Presente', 'icon_code': 0xe1bc, 'color_value': 0xFF9C27B0, 'type': 'income'},
      {'name': 'Outros', 'icon_code': 0xe5d3, 'color_value': 0xFF607D8B, 'type': 'income'},
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
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
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
    final result = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
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
    return db.update(
      'transactions',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
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

  Future<List<TransactionModel>> getTransactionsByMonth(
    int userId,
    int year,
    int month,
  ) async {
    final db = await database;
    final from = DateTime(year, month, 1).toIso8601String();
    final to = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();
    final result = await db.query(
      'transactions',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, from, to],
      orderBy: 'date DESC',
    );
    return result.map(TransactionModel.fromMap).toList();
  }
}
