import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

class FinanceProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.type == 'income').toList();

  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.type == 'expense').toList();

  List<TransactionModel> get incomeTransactions =>
      _transactions.where((t) => t.isIncome).toList();

  List<TransactionModel> get expenseTransactions =>
      _transactions.where((t) => !t.isIncome).toList();

  double get totalIncome =>
      incomeTransactions.fold(0, (sum, t) => sum + t.amount);

  double get totalExpense =>
      expenseTransactions.fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  List<TransactionModel> get thisMonthTransactions {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();
  }

  double get thisMonthIncome => thisMonthTransactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get thisMonthExpense => thisMonthTransactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  List<TransactionModel> get recentTransactions =>
      _transactions.take(5).toList();

  CategoryModel? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Gastos agrupados por categoria (para gráfico de pizza)
  Map<CategoryModel, double> get expensesByCategory {
    final map = <CategoryModel, double>{};
    for (final tx in thisMonthTransactions.where((t) => !t.isIncome)) {
      final cat = getCategoryById(tx.categoryId);
      if (cat == null) continue;
      map[cat] = (map[cat] ?? 0) + tx.amount;
    }
    return map;
  }

  // Receitas e despesas dos últimos 6 meses (para gráfico de barras)
  List<Map<String, dynamic>> get lastSixMonthsData {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final month = DateTime(now.year, now.month - (5 - i), 1);
      final monthTxs = _transactions.where(
        (t) => t.date.year == month.year && t.date.month == month.month,
      );
      return {
        'month': month,
        'income': monthTxs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount),
        'expense': monthTxs.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount),
      };
    });
  }

  Future<void> loadData(int userId) async {
    _isLoading = true;
    notifyListeners();

    _categories = await DatabaseHelper.instance.getAllCategories();
    _transactions = await DatabaseHelper.instance.getTransactionsByUser(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction({
    required int userId,
    required String title,
    required double amount,
    required String type,
    required int categoryId,
    required DateTime date,
    String? description,
  }) async {
    final tx = TransactionModel(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      description: description,
    );

    await DatabaseHelper.instance.insertTransaction(tx);
    _transactions.insert(0, tx);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> editTransaction(TransactionModel updated) async {
    await DatabaseHelper.instance.updateTransaction(updated);
    final index = _transactions.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _transactions[index] = updated;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    }
    notifyListeners();
  }
}
