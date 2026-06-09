import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/finance_provider.dart';
import '../../../shared/widgets/budget_card.dart';
import '../widgets/home_hero_header.dart';
import '../../transactions/screens/add_transaction_screen.dart';
import '../../transactions/widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  /// Permite à Home trocar a aba ativa do MainScaffold (ex.: "Ver tudo").
  final ValueChanged<int>? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hideBalance = false;

  void _openEdit(TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionScreen(transaction: tx),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final finance = context.watch<FinanceProvider>();
    final fullName = auth.currentUser?.name ?? '';
    final firstName = fullName.split(' ').first;

    final income = finance.thisMonthIncome;
    final expense = finance.thisMonthExpense;
    final double? savingsRate = income > 0 ? ((income - expense) / income) * 100 : null;
    final now = DateTime.now();

    return Scaffold(
      body: finance.isLoading
          ? const SafeArea(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: HomeHeroHeader(
                    firstName: firstName,
                    initials: _initials(fullName),
                    photoPath: auth.currentUser?.photoPath,
                    balance: finance.balance,
                    income: income,
                    expense: expense,
                    savingsRate: savingsRate,
                    hideBalance: _hideBalance,
                    onToggleHide: () {
                      HapticFeedback.lightImpact();
                      setState(() => _hideBalance = !_hideBalance);
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BudgetCard(
                          budget: finance.monthlyBudget,
                          spent: expense,
                          monthLabel: Formatters.monthYear(now),
                        ),
                        const SizedBox(height: 28),
                        _buildSectionHeader(context),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                if (finance.recentTransactions.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tx = finance.recentTransactions[index];
                        final category = finance.getCategoryById(tx.categoryId);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          child: TransactionCard(
                            transaction: tx,
                            category: category,
                            onDelete: () {
                              finance.deleteTransaction(tx.id);
                              AppSnackbar.success(context, 'Transação excluída');
                            },
                            onTap: () => _openEdit(tx),
                          ),
                        );
                      },
                      childCount: finance.recentTransactions.length,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transações',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        InkWell(
          onTap: () => widget.onNavigateToTab?.call(1),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Text(
              'Ver tudo',
              style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text(
              'Nenhuma transação ainda',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            SizedBox(height: 4),
            Text(
              'Toque no + para adicionar sua primeira receita ou despesa',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
