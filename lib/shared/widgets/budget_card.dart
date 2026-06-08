import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import 'budget_dialog.dart';

/// Card de orçamento mensal com barra de progresso.
/// Compartilhado entre a Home e a tela de Relatórios.
class BudgetCard extends StatelessWidget {
  final double? budget;
  final double spent;
  final String monthLabel;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.monthLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final borderColor = Theme.of(context).dividerColor;

    if (budget == null) {
      return Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => showBudgetDialog(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: const Row(
              children: [
                Icon(Icons.savings_outlined, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Definir orçamento mensal',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                Icon(Icons.add, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      );
    }

    final budgetValue = budget!;
    final ratio = budgetValue > 0 ? spent / budgetValue : 0.0;
    final clamped = ratio.clamp(0.0, 1.0).toDouble();
    final over = ratio > 1.0;
    final color = over
        ? AppColors.expense
        : ratio >= 0.8
            ? AppColors.warning
            : AppColors.income;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Orçamento · $monthLabel',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                onPressed: () => showBudgetDialog(context),
                tooltip: 'Editar orçamento',
                padding: const EdgeInsets.only(left: 8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: 8,
              backgroundColor: borderColor,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${Formatters.currency(spent)} usados de ${Formatters.currency(budgetValue)}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          if (over) ...[
            const SizedBox(height: 2),
            Text(
              'Ultrapassou em ${Formatters.currency(spent - budgetValue)}.',
              style: const TextStyle(fontSize: 11, color: AppColors.expense),
            ),
          ],
        ],
      ),
    );
  }
}
