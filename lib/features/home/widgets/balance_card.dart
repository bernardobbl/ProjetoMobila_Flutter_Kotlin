import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// Bloco de visão geral da Home: saldo total como protagonista, variação do mês
/// e dois mini-cards planos (receitas e despesas).
class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  final double? savingsRate; // % poupado no mês; null esconde o selo
  final bool hideBalance;
  final VoidCallback onToggleHide;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    required this.savingsRate,
    required this.hideBalance,
    required this.onToggleHide,
  });

  static const _hidden = '••••••';

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Saldo total',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const Spacer(),
            InkWell(
              onTap: onToggleHide,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    key: ValueKey(hideBalance),
                    hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                  .animate(animation),
              child: child,
            ),
          ),
          child: Text(
            key: ValueKey(hideBalance),
            hideBalance ? _hidden : Formatters.currency(balance),
            style: TextStyle(
              color: textColor,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (savingsRate != null) ...[
          const SizedBox(height: 10),
          _TrendPill(rate: savingsRate!),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _MiniCard(
                label: 'Receitas',
                amount: income,
                color: AppColors.income,
                hide: hideBalance,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniCard(
                label: 'Despesas',
                amount: expense,
                color: AppColors.expense,
                hide: hideBalance,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrendPill extends StatelessWidget {
  final double rate;

  const _TrendPill({required this.rate});

  @override
  Widget build(BuildContext context) {
    final positive = rate >= 0;
    final color = positive ? AppColors.income : AppColors.expense;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(positive ? Icons.trending_up : Icons.trending_down, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            '${rate.abs().toStringAsFixed(1)}% poupado este mês',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool hide;

  const _MiniCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.hide,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = color == AppColors.income;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hide ? '••••' : '${isIncome ? '+ ' : '- '}${Formatters.currency(amount)}',
            style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          const Text('este mês', style: TextStyle(color: AppColors.textHint, fontSize: 11)),
        ],
      ),
    );
  }
}
