import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF9D8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.40),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo Total',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          // Contador animado — anima quando o saldo muda
          TweenAnimationBuilder<double>(
            key: ValueKey(balance),
            tween: Tween(begin: 0, end: balance),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => Text(
              Formatters.currency(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.monthYear(DateTime.now()),
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(label: 'Receitas', amount: income, isIncome: true),
                ),
                Container(width: 1, height: 36, color: Colors.white24),
                Expanded(
                  child: _StatItem(label: 'Despesas', amount: expense, isIncome: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final double amount;
  final bool isIncome;

  const _StatItem({
    required this.label,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: isIncome ? 0 : 16, right: isIncome ? 16 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: isIncome ? const Color(0xFF90EE90) : const Color(0xFFFFAA99),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            key: ValueKey(amount),
            tween: Tween(begin: 0, end: amount),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => Text(
              Formatters.currency(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
