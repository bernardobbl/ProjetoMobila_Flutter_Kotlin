import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';

class HomeHeroHeader extends StatelessWidget {
  final String firstName;
  final String initials;
  final String? photoPath;
  final double balance;
  final double income;
  final double expense;
  final double? savingsRate;
  final bool hideBalance;
  final VoidCallback onToggleHide;

  const HomeHeroHeader({
    super.key,
    required this.firstName,
    required this.initials,
    this.photoPath,
    required this.balance,
    required this.income,
    required this.expense,
    this.savingsRate,
    required this.hideBalance,
    required this.onToggleHide,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ClipPath(
        clipper: _ArchClipper(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF091830),
                Color(0xFF0D2461),
                Color(0xFF1A4CB8),
              ],
              stops: [0.0, 0.52, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Blob decorativo — topo direito
              Positioned(
                top: -50, right: -60,
                child: _Blob(size: 260, color: AppColors.primary, opacity: 0.18),
              ),
              // Blob decorativo — meio esquerdo
              Positioned(
                top: 70, left: -55,
                child: _Blob(size: 170, color: const Color(0xFF6F9DFF), opacity: 0.11),
              ),
              // Blob decorativo — canto inferior direito
              Positioned(
                bottom: 24, right: 16,
                child: _Blob(size: 100, color: AppColors.primaryLight, opacity: 0.13),
              ),
              // Conteúdo principal
              Padding(
                padding: EdgeInsets.fromLTRB(20, topPad + 18, 20, 52),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GreetingRow(
                      greeting: greeting,
                      firstName: firstName,
                      initials: initials,
                      photoPath: photoPath,
                    ),
                    const SizedBox(height: 28),
                    _BalanceSection(
                      balance: balance,
                      savingsRate: savingsRate,
                      hideBalance: hideBalance,
                      onToggleHide: onToggleHide,
                    ),
                    const SizedBox(height: 20),
                    _MiniCardsRow(
                      income: income,
                      expense: expense,
                      hide: hideBalance,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Linha de saudação + avatar ─────────────────────────────────────────────

class _GreetingRow extends StatelessWidget {
  final String greeting;
  final String firstName;
  final String initials;
  final String? photoPath;

  const _GreetingRow({
    required this.greeting,
    required this.firstName,
    required this.initials,
    this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && File(photoPath!).existsSync();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                firstName.isEmpty ? 'Olá' : firstName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: hasPhoto ? null : Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1.5,
            ),
          ),
          child: hasPhoto
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12.5),
                  child: Image.file(
                    File(photoPath!),
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Seção de saldo ──────────────────────────────────────────────────────────

class _BalanceSection extends StatelessWidget {
  final double balance;
  final double? savingsRate;
  final bool hideBalance;
  final VoidCallback onToggleHide;

  static const _hidden = '••••••';

  const _BalanceSection({
    required this.balance,
    required this.savingsRate,
    required this.hideBalance,
    required this.onToggleHide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Saldo total',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: 14,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onToggleHide,
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.white.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    key: ValueKey(hideBalance),
                    hideBalance
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.62),
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
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            key: ValueKey(hideBalance),
            hideBalance ? _hidden : Formatters.currency(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (savingsRate != null) ...[
          const SizedBox(height: 10),
          _TrendPill(rate: savingsRate!),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            '${rate.abs().toStringAsFixed(1)}% poupado este mês',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mini-cards glassmorphism ────────────────────────────────────────────────

class _MiniCardsRow extends StatelessWidget {
  final double income;
  final double expense;
  final bool hide;

  const _MiniCardsRow({
    required this.income,
    required this.expense,
    required this.hide,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GlassMiniCard(
            label: 'Receitas',
            amount: income,
            isIncome: true,
            hide: hide,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GlassMiniCard(
            label: 'Despesas',
            amount: expense,
            isIncome: false,
            hide: hide,
          ),
        ),
      ],
    );
  }
}

class _GlassMiniCard extends StatelessWidget {
  final String label;
  final double amount;
  final bool isIncome;
  final bool hide;

  const _GlassMiniCard({
    required this.label,
    required this.amount,
    required this.isIncome,
    required this.hide,
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? AppColors.income : AppColors.expense;
    final prefix = isIncome ? '+ ' : '- ';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            hide ? '••••' : '$prefix${Formatters.currency(amount)}',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'este mês',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Blob decorativo ────────────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Blob({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), Colors.transparent],
        ),
      ),
    );
  }
}

// ─── Clipper com arco fluido na base ────────────────────────────────────────

class _ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 36)
      ..quadraticBezierTo(
        size.width / 2, size.height + 8,
        size.width, size.height - 36,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
