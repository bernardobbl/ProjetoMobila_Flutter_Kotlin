import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/recurring_model.dart';

class FinanceProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  final _db = DatabaseHelper.instance;

  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  List<RecurringModel> _recurringRules = [];
  double? _monthlyBudget;
  int? _currentUserId;
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  List<RecurringModel> get recurringRules => _recurringRules;
  double? get monthlyBudget => _monthlyBudget;
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

  // ─── Filtros por mês ──────────────────────────────────────────────────

  List<TransactionModel> transactionsForMonth(DateTime month) => _transactions
      .where((t) => t.date.year == month.year && t.date.month == month.month)
      .toList();

  double incomeForMonth(DateTime month) => transactionsForMonth(month)
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double expenseForMonth(DateTime month) => transactionsForMonth(month)
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  /// Gastos por categoria de um mês (para o gráfico de pizza).
  Map<CategoryModel, double> expensesByCategoryForMonth(DateTime month) {
    final map = <CategoryModel, double>{};
    for (final tx in transactionsForMonth(month).where((t) => !t.isIncome)) {
      final cat = getCategoryById(tx.categoryId);
      if (cat == null) continue;
      map[cat] = (map[cat] ?? 0) + tx.amount;
    }
    return map;
  }

  // Atalhos para o mês atual (usados na Home).
  List<TransactionModel> get thisMonthTransactions =>
      transactionsForMonth(DateTime.now());
  double get thisMonthIncome => incomeForMonth(DateTime.now());
  double get thisMonthExpense => expenseForMonth(DateTime.now());

  List<TransactionModel> get recentTransactions =>
      _transactions.take(5).toList();

  CategoryModel? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Receitas e despesas dos últimos 6 meses (para o gráfico de barras),
  /// terminando no [reference] (padrão: mês atual).
  List<Map<String, dynamic>> lastSixMonthsData([DateTime? reference]) {
    final ref = reference ?? DateTime.now();
    return List.generate(6, (i) {
      final month = DateTime(ref.year, ref.month - (5 - i), 1);
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

  // ─── Orçamento mensal ─────────────────────────────────────────────────

  /// Quanto do orçamento já foi gasto no [month] (0.0 a 1.0+). null se sem meta.
  double? budgetProgress(DateTime month) {
    final budget = _monthlyBudget;
    if (budget == null || budget <= 0) return null;
    return expenseForMonth(month) / budget;
  }

  Future<void> setMonthlyBudget(double amount) async {
    final userId = _currentUserId;
    if (userId == null) return;
    await _db.setBudget(BudgetModel(userId: userId, amount: amount));
    _monthlyBudget = amount;
    notifyListeners();
  }

  Future<void> removeMonthlyBudget() async {
    final userId = _currentUserId;
    if (userId == null) return;
    await _db.deleteBudget(userId);
    _monthlyBudget = null;
    notifyListeners();
  }

  // ─── Carregamento ─────────────────────────────────────────────────────

  Future<void> loadData(int userId) async {
    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    // Gera as transações recorrentes que venceram desde a última abertura.
    await _generateDueRecurring(userId);

    _categories = await _db.getAllCategories();
    _transactions = await _db.getTransactionsByUser(userId);
    _recurringRules = await _db.getRecurringByUser(userId);
    _monthlyBudget = (await _db.getBudget(userId))?.amount;

    _isLoading = false;
    notifyListeners();
  }

  // ─── Transações ───────────────────────────────────────────────────────

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

    await _db.insertTransaction(tx);
    _transactions.insert(0, tx);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> editTransaction(TransactionModel updated) async {
    await _db.updateTransaction(updated);
    final index = _transactions.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _transactions[index] = updated;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    }
    notifyListeners();
  }

  // ─── Categorias (CRUD) ────────────────────────────────────────────────

  Future<void> addCategory({
    required String name,
    required String iconName,
    required int colorValue,
    required String type,
  }) async {
    final category = CategoryModel(
      name: name,
      iconName: iconName,
      colorValue: colorValue,
      type: type,
      isDefault: false,
    );
    await _db.insertCategory(category);
    _categories = await _db.getAllCategories();
    notifyListeners();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _db.updateCategory(category);
    _categories = await _db.getAllCategories();
    notifyListeners();
  }

  /// Quantas transações usam uma categoria (para decidir se pode excluir).
  Future<int> transactionCountForCategory(int categoryId) =>
      _db.countTransactionsForCategory(categoryId);

  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);
    _categories = await _db.getAllCategories();
    notifyListeners();
  }

  // ─── Transações recorrentes ───────────────────────────────────────────

  Future<void> addRecurring({
    required int userId,
    required String title,
    required double amount,
    required String type,
    required int categoryId,
    required int dayOfMonth,
  }) async {
    final rule = RecurringModel(
      id: _uuid.v4(),
      userId: userId,
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      dayOfMonth: dayOfMonth,
      startDate: DateTime.now(),
    );
    await _db.insertRecurring(rule);
    // Recarrega tudo (a geração roda em loadData e já lança o mês corrente se cabível).
    await loadData(userId);
  }

  Future<void> deleteRecurring(String id) async {
    await _db.deleteRecurring(id);
    _recurringRules.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  /// Gera as transações recorrentes pendentes desde a última geração.
  Future<void> _generateDueRecurring(int userId) async {
    final rules = await _db.getRecurringByUser(userId);
    final now = DateTime.now();

    for (final rule in rules) {
      final dueDates = _dueDatesFor(rule, now);
      if (dueDates.isEmpty) continue;

      for (final date in dueDates) {
        final tx = TransactionModel(
          id: _uuid.v4(),
          userId: userId,
          title: rule.title,
          amount: rule.amount,
          type: rule.type,
          categoryId: rule.categoryId,
          date: date,
          description: 'Lançamento recorrente',
        );
        await _db.insertTransaction(tx);
      }

      final last = dueDates.last;
      await _db.updateRecurring(
        rule.copyWith(lastGenerated: DateTime(last.year, last.month, 1)),
      );
    }
  }

  /// Calcula em quais datas uma regra deve gerar transações até [now].
  List<DateTime> _dueDatesFor(RecurringModel rule, DateTime now) {
    final dates = <DateTime>[];

    // Primeiro mês a considerar.
    DateTime cursor = rule.lastGenerated != null
        ? DateTime(rule.lastGenerated!.year, rule.lastGenerated!.month + 1, 1)
        : DateTime(rule.startDate.year, rule.startDate.month, 1);

    final currentMonth = DateTime(now.year, now.month, 1);
    final startDay =
        DateTime(rule.startDate.year, rule.startDate.month, rule.startDate.day);

    while (!cursor.isAfter(currentMonth)) {
      final day = _clampDay(rule.dayOfMonth, cursor.year, cursor.month);
      final txDate = DateTime(cursor.year, cursor.month, day);
      if (!txDate.isBefore(startDay) && !txDate.isAfter(now)) {
        dates.add(txDate);
      }
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }
    return dates;
  }

  int _clampDay(int day, int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day; // último dia do mês
    if (day < 1) return 1;
    if (day > lastDay) return lastDay;
    return day;
  }
}
