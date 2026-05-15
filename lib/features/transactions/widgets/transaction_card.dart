import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/transaction_model.dart';
import '../../../models/category_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.category,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _CategoryIcon(category: category),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category?.name ?? 'Sem categoria',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.isIncome ? '+' : '-'} ${Formatters.currency(transaction.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: transaction.isIncome ? AppColors.income : AppColors.expense,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.dateShort(transaction.date),
                      style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                    ),
                  ],
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, size: 18, color: AppColors.textHint),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir transação'),
        content: Text('Deseja excluir "${transaction.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final CategoryModel? category;

  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = category?.color ?? AppColors.primary;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(category?.icon ?? Icons.category_outlined, color: color, size: 22),
    );
  }
}
