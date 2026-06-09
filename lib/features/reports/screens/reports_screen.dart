import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/finance_provider.dart';
import '../../../shared/widgets/budget_card.dart';
import '../../transactions/services/csv_exporter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _touchedIndex = -1;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
      _touchedIndex = -1;
    });
  }

  Future<void> _exportCsv(FinanceProvider finance) async {
    final messenger = ScaffoldMessenger.of(context);
    final monthTxs = finance.transactionsForMonth(_selectedMonth);
    if (monthTxs.isEmpty) {
      AppSnackbar.error(context, 'Não há transações para exportar neste mês.');
      return;
    }
    try {
      await CsvExporter.exportTransactions(
        monthTxs,
        finance.getCategoryById,
      );
    } catch (e, st) {
      debugPrint('CSV export error: $e\n$st');
      AppSnackbar.errorWith(messenger, 'Não foi possível exportar o CSV.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: AppColors.primary),
            tooltip: 'Exportar CSV',
            onPressed: () => _exportCsv(finance),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: finance.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _MonthSelector(
                  month: _selectedMonth,
                  canGoNext: !_isCurrentMonth,
                  onPrevious: () => _changeMonth(-1),
                  onNext: () => _changeMonth(1),
                ),
                const SizedBox(height: 16),
                _SummaryHeader(finance: finance, month: _selectedMonth),
                const SizedBox(height: 16),
                BudgetCard(
                  budget: finance.monthlyBudget,
                  spent: finance.expenseForMonth(_selectedMonth),
                  monthLabel: Formatters.monthYear(_selectedMonth),
                ),
                const SizedBox(height: 24),
                _SectionLabel(label: 'Gastos por categoria — ${Formatters.monthYear(_selectedMonth)}'),
                const SizedBox(height: 16),
                _ExpensePieChart(
                  finance: finance,
                  month: _selectedMonth,
                  touchedIndex: _touchedIndex,
                  onTouch: (i) => setState(() => _touchedIndex = i),
                ),
                const SizedBox(height: 24),
                const _SectionLabel(label: 'Receitas vs Despesas — últimos 6 meses'),
                const SizedBox(height: 16),
                _MonthlyBarChart(finance: finance, reference: _selectedMonth),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime month;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.month,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
            tooltip: 'Mês anterior',
          ),
          Text(
            Formatters.monthYear(month),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: canGoNext ? onNext : null,
            tooltip: 'Próximo mês',
          ),
        ],
      ),
    );
  }
}


class _SummaryHeader extends StatelessWidget {
  final FinanceProvider finance;
  final DateTime month;

  const _SummaryHeader({required this.finance, required this.month});

  @override
  Widget build(BuildContext context) {
    final income = finance.incomeForMonth(month);
    final expense = finance.expenseForMonth(month);
    final saved = income - expense;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Receitas',
            value: income,
            color: AppColors.income,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Despesas',
            value: expense,
            color: AppColors.expense,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Saldo',
            value: saved,
            color: saved >= 0 ? AppColors.income : AppColors.expense,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            Formatters.currency(value.abs()),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }
}

class _ExpensePieChart extends StatelessWidget {
  final FinanceProvider finance;
  final DateTime month;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _ExpensePieChart({
    required this.finance,
    required this.month,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final expensesByCategory = finance.expensesByCategoryForMonth(month);

    if (expensesByCategory.isEmpty) {
      return _emptyChart(context, 'Nenhuma despesa registrada neste mês');
    }

    final entries = expensesByCategory.entries.toList();
    final total = entries.fold(0.0, (s, e) => s + e.value);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: List.generate(entries.length, (i) {
                  final entry = entries[i];
                  final isTouched = i == touchedIndex;
                  final pct = (entry.value / total * 100).toStringAsFixed(1);
                  return PieChartSectionData(
                    color: entry.key.color,
                    value: entry.value,
                    title: isTouched ? '$pct%' : '',
                    radius: isTouched ? 70 : 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  );
                }),
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (response?.touchedSection != null) {
                      onTouch(response!.touchedSection!.touchedSectionIndex);
                    } else {
                      onTouch(-1);
                    }
                  },
                ),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: entries.map((e) {
              final pct = (e.value / total * 100).toStringAsFixed(0);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: e.key.color, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(
                      '${e.key.name} $pct%',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _emptyChart(BuildContext context, String message) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pie_chart_outline, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final FinanceProvider finance;
  final DateTime reference;

  const _MonthlyBarChart({required this.finance, required this.reference});

  @override
  Widget build(BuildContext context) {
    final data = finance.lastSixMonthsData(reference);
    final maxY = data.fold<double>(0, (max, d) {
      final m = [d['income'] as double, d['expense'] as double].reduce((a, b) => a > b ? a : b);
      return m > max ? m : max;
    });

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY == 0 ? 100 : maxY * 1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final month = data[value.toInt()]['month'] as DateTime;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            Formatters.monthShort(month),
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.divider, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(data.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i]['income'] as double,
                        color: AppColors.income,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: data[i]['expense'] as double,
                        color: AppColors.expense,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: AppColors.income, label: 'Receitas'),
              SizedBox(width: 20),
              _Legend(color: AppColors.expense, label: 'Despesas'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
