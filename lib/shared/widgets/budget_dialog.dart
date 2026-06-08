import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../../core/utils/formatters.dart';
import '../../providers/finance_provider.dart';

/// Diálogo compartilhado para definir/remover o orçamento mensal.
/// Usado tanto na Home quanto na tela de Relatórios.
Future<void> showBudgetDialog(BuildContext context) async {
  final finance = context.read<FinanceProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final controller = TextEditingController(
    text: finance.monthlyBudget != null
        ? finance.monthlyBudget!.toStringAsFixed(2).replaceAll('.', ',')
        : '',
  );

  final result = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Orçamento mensal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Defina quanto pretende gastar por mês. O progresso aparece na Home e nos Relatórios.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]'))],
            decoration: const InputDecoration(
              labelText: 'Valor (R\$)',
              hintText: '0,00',
              prefixIcon: Icon(Icons.attach_money, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      actions: [
        if (finance.monthlyBudget != null)
          TextButton(
            onPressed: () => Navigator.pop(context, 'remove'),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Remover'),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Salvar'),
        ),
      ],
    ),
  );

  if (result == null) return;
  if (result == 'remove') {
    await finance.removeMonthlyBudget();
    AppSnackbar.successWith(messenger, 'Orçamento removido');
    return;
  }
  final amount = Formatters.parseAmount(result);
  if (amount == null || amount <= 0) {
    AppSnackbar.errorWith(messenger, 'Valor inválido');
    return;
  }
  await finance.setMonthlyBudget(amount);
  AppSnackbar.successWith(messenger, 'Orçamento definido!');
}
