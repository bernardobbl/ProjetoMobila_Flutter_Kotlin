import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/category_model.dart';
import '../../../models/recurring_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/finance_provider.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final rules = finance.recurringRules;

    return Scaffold(
      appBar: AppBar(title: const Text('Transações recorrentes')),
      body: rules.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: rules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _RecurringTile(rule: rules[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova regra', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.repeat, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text('Nenhuma recorrência cadastrada',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            SizedBox(height: 4),
            Text(
              'Cadastre lançamentos que se repetem todo mês\n(ex.: aluguel, salário, assinaturas).',
              style: TextStyle(color: AppColors.textHint, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

void _openForm(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RecurringFormSheet(),
  );
}

class _RecurringTile extends StatelessWidget {
  final RecurringModel rule;

  const _RecurringTile({required this.rule});

  Future<void> _confirmDelete(BuildContext context) async {
    final finance = context.read<FinanceProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir recorrência'),
        content: Text(
            'Excluir a regra "${rule.title}"? As transações já lançadas não serão removidas.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await finance.deleteRecurring(rule.id);
      AppSnackbar.successWith(messenger, 'Recorrência excluída');
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.read<FinanceProvider>();
    final category = finance.getCategoryById(rule.categoryId);
    final color = rule.isIncome ? AppColors.income : AppColors.expense;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (category?.color ?? AppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category?.icon ?? Icons.repeat, color: category?.color ?? AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  'Todo dia ${rule.dayOfMonth} • ${category?.name ?? 'Sem categoria'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${rule.isIncome ? '+' : '-'} ${Formatters.currency(rule.amount)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textHint),
                onPressed: () => _confirmDelete(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecurringFormSheet extends StatefulWidget {
  const _RecurringFormSheet();

  @override
  State<_RecurringFormSheet> createState() => _RecurringFormSheetState();
}

class _RecurringFormSheetState extends State<_RecurringFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  String _type = 'expense';
  int _day = 1;
  CategoryModel? _selectedCategory;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  List<CategoryModel> get _categories {
    final finance = context.read<FinanceProvider>();
    return _type == 'income' ? finance.incomeCategories : finance.expenseCategories;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      AppSnackbar.error(context, 'Selecione uma categoria');
      return;
    }
    final finance = context.read<FinanceProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final userId = context.read<AuthProvider>().currentUser!.id!;
    final amount = Formatters.parseAmount(_amountCtrl.text) ?? 0;

    await finance.addRecurring(
      userId: userId,
      title: _titleCtrl.text.trim(),
      amount: amount,
      type: _type,
      categoryId: _selectedCategory!.id!,
      dayOfMonth: _day,
    );

    if (!mounted) return;
    Navigator.pop(context);
    AppSnackbar.successWith(messenger, 'Recorrência criada!');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Nova recorrência',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _TypeToggle(
                selected: _type,
                onChanged: (t) => setState(() {
                  _type = t;
                  _selectedCategory = null;
                }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex: Aluguel, Salário, Netflix...',
                  prefixIcon: Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]'))],
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  hintText: '0,00',
                  prefixIcon: Icon(Icons.attach_money, color: AppColors.textSecondary),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o valor';
                  final val = Formatters.parseAmount(v);
                  if (val == null || val <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.event_repeat, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  const Text('Lançar todo dia', style: TextStyle(fontSize: 14)),
                  const Spacer(),
                  DropdownButton<int>(
                    value: _day,
                    items: List.generate(28, (i) => i + 1)
                        .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                        .toList(),
                    onChanged: (v) => setState(() => _day = v ?? 1),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Categoria',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final selected = _selectedCategory?.id == cat.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? cat.color.withValues(alpha: 0.15) : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? cat.color : AppColors.divider,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, color: cat.color, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              color: selected ? cat.color : Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Criar recorrência')),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _TypeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ToggleOption(label: 'Despesa', isSelected: selected == 'expense', color: AppColors.expense, onTap: () => onChanged('expense')),
          _ToggleOption(label: 'Receita', isSelected: selected == 'income', color: AppColors.income, onTap: () => onChanged('income')),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
