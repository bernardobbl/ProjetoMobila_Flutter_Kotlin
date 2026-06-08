import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/finance_provider.dart';
import '../../../shared/widgets/budget_card.dart';
import '../widgets/balance_card.dart';
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
      body: SafeArea(
        child: finance.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGreeting(context, firstName, _initials(fullName)),
                          const SizedBox(height: 28),
                          BalanceCard(
                            balance: finance.balance,
                            income: income,
                            expense: expense,
                            savingsRate: savingsRate,
                            hideBalance: _hideBalance,
                            onToggleHide: () => setState(() => _hideBalance = !_hideBalance),
                          ),
                          const SizedBox(height: 16),
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
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String firstName, String initials) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting,', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                firstName.isEmpty ? 'Olá' : firstName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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
        GestureDetector(
          onTap: () => widget.onNavigateToTab?.call(1),
          child: const Text(
            'Ver tudo',
            style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
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
            Text('Nenhuma transação ainda', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
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
