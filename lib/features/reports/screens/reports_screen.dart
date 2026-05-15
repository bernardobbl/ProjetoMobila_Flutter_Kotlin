import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/finance_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: finance.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SummaryHeader(finance: finance),
                const SizedBox(height: 24),
                _SectionLabel(label: 'Gastos por categoria — ${Formatters.monthYear(DateTime.now())}'),
                const SizedBox(height: 16),
                _ExpensePieChart(finance: finance, touchedIndex: _touchedIndex, onTouch: (i) => setState(() => _touchedIndex = i)),
                const SizedBox(height: 24),
                _SectionLabel(label: 'Receitas vs Despesas — últimos 6 meses'),
                const SizedBox(height: 16),
                _MonthlyBarChart(finance: finance),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final FinanceProvider finance;

  const _SummaryHeader({required this.finance});

  @override
  Widget build(BuildContext context) {
    final saved = finance.thisMonthIncome - finance.thisMonthExpense;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Receitas',
            value: finance.thisMonthIncome,
            color: AppColors.income,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Despesas',
            value: finance.thisMonthExpense,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
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
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    );
  }
}

class _ExpensePieChart extends StatelessWidget {
  final FinanceProvider finance;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _ExpensePieChart({
    required this.finance,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final expensesByCategory = finance.expensesByCategory;

    if (expensesByCategory.isEmpty) {
      return _emptyChart('Nenhuma despesa registrada neste mês');
    }

    final entries = expensesByCategory.entries.toList();
    final total = entries.fold(0.0, (s, e) => s + e.value);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
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
                  Text('${e.key.name} $pct%', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _emptyChart(String message) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
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

  const _MonthlyBarChart({required this.finance});

  @override
  Widget build(BuildContext context) {
    final data = finance.lastSixMonthsData;
    final maxY = data.fold<double>(0, (max, d) {
      final m = [d['income'] as double, d['expense'] as double].reduce((a, b) => a > b ? a : b);
      return m > max ? m : max;
    });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
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
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.divider, strokeWidth: 1),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: AppColors.income, label: 'Receitas'),
              const SizedBox(width: 20),
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
