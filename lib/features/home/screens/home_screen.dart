import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/finance_provider.dart';
import '../widgets/balance_card.dart';
import '../../transactions/screens/add_transaction_screen.dart';
import '../../transactions/widgets/transaction_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final finance = context.watch<FinanceProvider>();
    final firstName = auth.currentUser?.name.split(' ').first ?? '';

    return Scaffold(
      body: SafeArea(
        child: finance.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGreeting(context, firstName),
                          const SizedBox(height: 24),
                          BalanceCard(
                            balance: finance.balance,
                            income: finance.thisMonthIncome,
                            expense: finance.thisMonthExpense,
                          ),
                          const SizedBox(height: 32),
                          _buildSectionHeader(
                            context,
                            title: 'Últimas transações',
                            onViewAll: () {
                              // Navegar para aba de transações
                            },
                          ),
                          const SizedBox(height: 12),
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
                              onDelete: () => finance.deleteTransaction(tx.id),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTransaction(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova transação', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 4,
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String firstName) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bom dia';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $firstName!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              Formatters.dateLong(DateTime.now()),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    VoidCallback? onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              'Ver todas',
              style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500),
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
              'Adicione sua primeira receita ou despesa',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionScreen(),
    );
  }
}
