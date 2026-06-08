import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/category_model.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/finance_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class AddTransactionScreen extends StatefulWidget {
  // Passando uma transação existente ativa o modo de edição
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  bool get isEditing => transaction != null;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  late String _type;
  CategoryModel? _selectedCategory;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      final tx = widget.transaction!;
      _type = tx.type;
      _selectedDate = tx.date;
      _titleCtrl.text = tx.title;
      _amountCtrl.text = tx.amount.toStringAsFixed(2).replaceAll('.', ',');
      _dateCtrl.text = Formatters.dateShort(tx.date);
      // Categoria será resolvida após o build, no _afterBuild
      WidgetsBinding.instance.addPostFrameCallback((_) => _resolveCategory());
    } else {
      _type = 'expense';
      _selectedDate = DateTime.now();
      _dateCtrl.text = Formatters.dateShort(_selectedDate);
    }
  }

  void _resolveCategory() {
    if (!widget.isEditing) return;
    final finance = context.read<FinanceProvider>();
    final cat = finance.getCategoryById(widget.transaction!.categoryId);
    if (cat != null) setState(() => _selectedCategory = cat);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  List<CategoryModel> get _categories {
    final finance = context.read<FinanceProvider>();
    return _type == 'income' ? finance.incomeCategories : finance.expenseCategories;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = Formatters.dateShort(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione uma categoria'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final amount = Formatters.parseAmount(_amountCtrl.text) ?? 0;
    final finance = context.read<FinanceProvider>();
    // Capturamos o messenger antes de fechar o bottom sheet, pois o contexto
    // deste sheet deixa de existir após o Navigator.pop.
    final messenger = ScaffoldMessenger.of(context);
    final wasEditing = widget.isEditing;

    if (widget.isEditing) {
      final updated = widget.transaction!.copyWith(
        title: _titleCtrl.text.trim(),
        amount: amount,
        type: _type,
        categoryId: _selectedCategory!.id!,
        date: _selectedDate,
      );
      await finance.editTransaction(updated);
    } else {
      final userId = context.read<AuthProvider>().currentUser!.id!;
      await finance.addTransaction(
        userId: userId,
        title: _titleCtrl.text.trim(),
        amount: amount,
        type: _type,
        categoryId: _selectedCategory!.id!,
        date: _selectedDate,
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
    AppSnackbar.successWith(
      messenger,
      wasEditing ? 'Transação atualizada!' : 'Transação adicionada!',
    );
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
              Text(
                widget.isEditing ? 'Editar Transação' : 'Nova Transação',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _TypeToggle(
                selected: _type,
                onChanged: (type) => setState(() {
                  _type = type;
                  _selectedCategory = null;
                }),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex: Almoço, Salário...',
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
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Data',
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              _CategorySelector(
                categories: _categories,
                selected: _selectedCategory,
                onSelected: (cat) => setState(() => _selectedCategory = cat),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: widget.isEditing ? 'Salvar alterações' : 'Salvar transação',
                onPressed: _save,
                isLoading: _isLoading,
              ),
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
          _ToggleOption(label: 'Despesa', icon: Icons.arrow_downward_rounded, isSelected: selected == 'expense', color: AppColors.expense, onTap: () => onChanged('expense')),
          _ToggleOption(label: 'Receita', icon: Icons.arrow_upward_rounded, isSelected: selected == 'income', color: AppColors.income, onTap: () => onChanged('income')),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.textSecondary, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final List<CategoryModel> categories;
  final CategoryModel? selected;
  final ValueChanged<CategoryModel> onSelected;

  const _CategorySelector({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoria',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = selected?.id == cat.id;
            return GestureDetector(
              onTap: () => onSelected(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? cat.color.withValues(alpha: 0.15) : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? cat.color : AppColors.divider,
                    width: isSelected ? 1.5 : 1,
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
                        color: isSelected
                            ? cat.color
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
