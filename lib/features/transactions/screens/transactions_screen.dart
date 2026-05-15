import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/finance_provider.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'all'; // 'all' | 'income' | 'expense'

  void _openAdd() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionScreen(),
    );
  }

  void _openEdit(TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionScreen(transaction: tx),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    final filtered = switch (_filter) {
      'income' => finance.incomeTransactions,
      'expense' => finance.expenseTransactions,
      _ => finance.transactions,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              tooltip: 'Nova transação',
              onPressed: _openAdd,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(current: _filter, onChanged: (f) => setState(() => _filter = f)),
          Expanded(
            child: finance.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : filtered.isEmpty
                    ? _buildEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final tx = filtered[index];
                          final category = finance.getCategoryById(tx.categoryId);
                          return TransactionCard(
                            transaction: tx,
                            category: category,
                            onDelete: () => finance.deleteTransaction(tx.id),
                            onTap: () => _openEdit(tx),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _filter == 'income' ? Icons.arrow_upward_rounded : Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text('Nenhuma transação encontrada', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _FilterBar({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _FilterChip(label: 'Todas', value: 'all', current: current, onTap: onChanged),
          const SizedBox(width: 8),
          _FilterChip(label: 'Receitas', value: 'income', current: current, onTap: onChanged),
          const SizedBox(width: 8),
          _FilterChip(label: 'Despesas', value: 'expense', current: current, onTap: onChanged),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
