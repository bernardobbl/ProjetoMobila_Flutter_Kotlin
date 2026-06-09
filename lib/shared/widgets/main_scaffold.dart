import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/transactions/screens/transactions_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(onNavigateToTab: _goToTab),
    const TransactionsScreen(),
    const ReportsScreen(),
    const ProfileScreen(),
  ];

  void _goToTab(int index) => setState(() => _currentIndex = index);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<FinanceProvider>().loadData(userId);
      }
    });
  }

  void _openAdd() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _openAdd();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        currentIndex: _currentIndex,
        onTap: _goToTab,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? AppColors.darkCard : AppColors.card;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.divider;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: BottomAppBar(
        color: barColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Início', index: 0, current: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Transações', index: 1, current: currentIndex, onTap: onTap),
            const SizedBox(width: 48), // espaço para o FAB central
            _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'Relatórios', index: 2, current: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Perfil', index: 3, current: currentIndex, onTap: onTap),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    final color = selected
        ? AppColors.primary
        : (Theme.of(context).brightness == Brightness.dark
            ? Colors.white38
            : AppColors.textSecondary);

    return Expanded(
      child: InkWell(
        onTap: () {
          if (index != current) HapticFeedback.selectionClick();
          onTap(index);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: Icon(selected ? activeIcon : icon, color: color, size: 24),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
