import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../providers/finance_provider.dart';
import '../../../models/category_model.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SectionTitle(
            title: 'Despesas',
            color: AppColors.expense,
            icon: Icons.arrow_downward_rounded,
          ),
          const SizedBox(height: 12),
          _CategoryGrid(categories: finance.expenseCategories),
          const SizedBox(height: 24),
          const _SectionTitle(
            title: 'Receitas',
            color: AppColors.income,
            icon: Icons.arrow_upward_rounded,
          ),
          const SizedBox(height: 12),
          _CategoryGrid(categories: finance.incomeCategories),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova categoria', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

void _openForm(BuildContext context, {CategoryModel? existing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategoryFormSheet(existing: existing),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;

  const _SectionTitle({required this.title, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;

  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => _CategoryTile(category: categories[index]),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (category.isDefault) {
            AppSnackbar.error(context, 'Categorias padrão não podem ser editadas');
          } else {
            _openForm(context, existing: category);
          }
        },
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(category.icon, color: category.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (!category.isDefault)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.edit, size: 13, color: AppColors.textHint),
              ),
          ],
        ),
      ),
    );
  }
}

/// Formulário (bottom sheet) para criar ou editar uma categoria personalizada.
class _CategoryFormSheet extends StatefulWidget {
  final CategoryModel? existing;

  const _CategoryFormSheet({this.existing});

  bool get isEditing => existing != null;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  // Paleta de cores (valores ARGB) para o seletor.
  static const List<int> _palette = [
    0xFF6C63FF, 0xFF4CAF50, 0xFFFF9800, 0xFFE91E63, 0xFF2196F3,
    0xFF9C27B0, 0xFF00BCD4, 0xFFFF5722, 0xFF795548, 0xFF607D8B,
    0xFF3F51B5, 0xFF009688,
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  late String _type;
  late String _iconName;
  late int _colorValue;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? 'expense';
    _iconName = e?.iconName ?? CategoryModel.availableIconNames.first;
    _colorValue = e?.colorValue ?? _palette.first;
    _nameCtrl.text = e?.name ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final finance = context.read<FinanceProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final name = _nameCtrl.text.trim();

    if (widget.isEditing) {
      await finance.updateCategory(
        widget.existing!.copyWith(
          name: name,
          iconName: _iconName,
          colorValue: _colorValue,
          type: _type,
        ),
      );
    } else {
      await finance.addCategory(
        name: name,
        iconName: _iconName,
        colorValue: _colorValue,
        type: _type,
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
    AppSnackbar.successWith(
      messenger,
      widget.isEditing ? 'Categoria atualizada!' : 'Categoria criada!',
    );
  }

  Future<void> _delete() async {
    final finance = context.read<FinanceProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final category = widget.existing!;

    final count = await finance.transactionCountForCategory(category.id!);
    if (!mounted) return;

    if (count > 0) {
      AppSnackbar.error(
        context,
        'Esta categoria está em uso por $count transação(ões) e não pode ser excluída.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir categoria'),
        content: Text('Deseja excluir "${category.name}"?'),
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

    if (confirmed != true) return;
    await finance.deleteCategory(category.id!);
    if (!mounted) return;
    Navigator.pop(context);
    AppSnackbar.successWith(messenger, 'Categoria excluída');
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = widget.isEditing && !widget.existing!.isDefault;
    final color = Color(_colorValue);

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
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(CategoryModel.iconForName(_iconName), color: color),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isEditing ? 'Editar categoria' : 'Nova categoria',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _TypeToggle(
                selected: _type,
                onChanged: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex: Assinaturas, Pets...',
                  prefixIcon: Icon(Icons.label_outline, color: AppColors.textSecondary),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 20),
              const Text('Ícone',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: CategoryModel.availableIconNames.map((name) {
                  final selected = name == _iconName;
                  return GestureDetector(
                    onTap: () => setState(() => _iconName = name),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected ? color.withValues(alpha: 0.15) : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? color : AppColors.divider,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        CategoryModel.iconForName(name),
                        color: selected ? color : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Cor',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _palette.map((value) {
                  final selected = value == _colorValue;
                  return GestureDetector(
                    onTap: () => setState(() => _colorValue = value),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(value),
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black, width: 2)
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text(widget.isEditing ? 'Salvar alterações' : 'Criar categoria'),
              ),
              if (canDelete) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline, color: AppColors.expense),
                  label: const Text('Excluir categoria', style: TextStyle(color: AppColors.expense)),
                ),
              ],
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
