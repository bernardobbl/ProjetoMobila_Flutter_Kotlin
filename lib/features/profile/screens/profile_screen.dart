import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/finance_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../categories/screens/categories_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final finance = context.watch<FinanceProvider>();
    final theme = context.watch<ThemeProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _UserCard(
            name: user?.name ?? '',
            email: user?.email ?? '',
            totalTransactions: finance.transactions.length,
          ),
          const SizedBox(height: 20),
          _StatsRow(finance: finance),
          const SizedBox(height: 28),
          const _SectionTitle(title: 'Preferências'),
          const SizedBox(height: 12),
          // Dark mode toggle
          _DarkModeTile(provider: theme),
          const SizedBox(height: 28),
          const _SectionTitle(title: 'Navegação'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.category_outlined,
            label: 'Ver categorias',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
          ),
          const SizedBox(height: 28),
          const _SectionTitle(title: 'Conta'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.info_outline,
            label: 'Sobre o FinanFlow',
            onTap: () => _showAbout(context),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.delete_outline,
            label: 'Limpar todas as transações',
            color: AppColors.expense,
            onTap: () => _confirmClearData(context, finance),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.logout,
            label: 'Sair da conta',
            color: AppColors.expense,
            onTap: () => _confirmLogout(context, auth),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primaryLight]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('FinanFlow'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versão 1.0.0'),
            SizedBox(height: 8),
            Text('App de finanças pessoais desenvolvido como projeto da disciplina de Desenvolvimento Mobile — UNIPE.'),
            SizedBox(height: 8),
            Text('Desenvolvido com Flutter.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }

  Future<void> _confirmClearData(BuildContext context, FinanceProvider finance) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpar dados'),
        content: const Text('Todas as transações serão excluídas permanentemente. Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final txCopy = List.of(finance.transactions);
      for (final tx in txCopy) {
        await finance.deleteTransaction(tx.id);
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true) await auth.logout();
  }
}

class _DarkModeTile extends StatelessWidget {
  final ThemeProvider provider;

  const _DarkModeTile({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: provider.toggleTheme,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(
                provider.isDarkMode ? Icons.dark_mode : Icons.light_mode_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Modo escuro',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              Switch(
                value: provider.isDarkMode,
                onChanged: (_) => provider.toggleTheme(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String name;
  final String email;
  final int totalTransactions;

  const _UserCard({required this.name, required this.email, required this.totalTransactions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  '$totalTransactions transações registradas',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final FinanceProvider finance;

  const _StatsRow({required this.finance});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Saldo total',
            value: Formatters.currency(finance.balance),
            color: finance.balance >= 0 ? AppColors.income : AppColors.expense,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Transações',
            value: '${finance.transactions.length}',
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary;
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: tileColor, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: tileColor, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              Icon(Icons.chevron_right, color: color ?? AppColors.textHint, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
