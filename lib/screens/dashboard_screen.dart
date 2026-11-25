
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gastoguard/screens/about_screen.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/screens/budget_settings_screen.dart';
import 'package:gastoguard/screens/help_support_screen.dart';
import 'package:gastoguard/screens/history_screen.dart';
import 'package:gastoguard/screens/spending_summary_screen.dart';
import 'package:gastoguard/services/budget_settings_scope.dart';
import 'package:gastoguard/services/dashboard_summary.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';
import 'package:gastoguard/utils/currency_formatter.dart';
import 'package:gastoguard/widgets/app_bottom_nav.dart';
import 'package:gastoguard/widgets/app_drawer.dart';
import 'package:gastoguard/widgets/balance_card.dart';
import 'package:gastoguard/widgets/gradient_button.dart';
import 'package:gastoguard/widgets/spending_pie_chart.dart';
import 'package:gastoguard/widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const String _userName = 'Renz';
  static const double _weeklyBudget = 1000;

  static const double _cardMargin = 22;
  static const double _sectionMargin = 33;
  static const double _legendGap = 12;
  static const double _legendMinWidth = 120;

  void _openAddTransaction(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AddTransactionScreen(),
      ),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const HistoryScreen(),
      ),
    );
  }

  void _openSummary(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SpendingSummaryScreen(),
      ),
    );
  }

  void _openBudgetSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BudgetSettingsScreen(),
      ),
    );
  }

  void _openAbout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AboutScreen(),
      ),
    );
  }

  void _openHelp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const HelpSupportScreen(),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is coming soon')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final store = TransactionScope.maybeOf(context);
    final budgetStore = BudgetSettingsScope.maybeOf(context);

    final summary = store == null
        ? DashboardSummary.sample
        : DashboardSummary.fromTransactions(store.transactions);

    final weeklyBudget =
        budgetStore?.weeklyLimit ?? _weeklyBudget;

    return Scaffold(
      drawer: AppDrawer(
        userName: _userName,
        onBudgetSettings: () => _openBudgetSettings(context),
        onAbout: () => _openAbout(context),
        onHelpAndSupport: () => _openHelp(context),
        onDarkMode: () => _showComingSoon(context, 'Dark Mode'),
        onDeleteData: () => _showComingSoon(context, 'Delete Data'),
      ),
      drawerScrimColor: const Color(0x1A000000),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxContentWidth,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _DashboardHeader(userName: _userName),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _cardMargin,
                    ),
                    child: BalanceCard(
                      remaining: summary.balance,
                      progress: summary.balanceShare,
                      weeklyBudget: weeklyBudget,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _cardMargin,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Income',
                            amount: formatPeso(summary.totalIncome),
                            icon: Icons.arrow_upward_rounded,
                            iconColor: AppColors.income,
                            borderColor: AppColors.incomeBorder,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            label: 'Spent',
                            amount: formatPeso(summary.totalExpenses),
                            icon: Icons.arrow_downward_rounded,
                            iconColor: AppColors.expense,
                            borderColor: AppColors.expenseBorder,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _sectionMargin,
                    ),
                    child: Text(
                      'Spending by Category',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _sectionMargin,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final pieSize = math.max(
                          96.0,
                          math.min(
                            constraints.maxWidth * 0.58,
                            constraints.maxWidth -
                                _legendGap -
                                _legendMinWidth,
                          ),
                        );

                        return Row(
                          children: [
                            SpendingPieChart(
                              slices: summary.pieSlices,
                              size: pieSize,
                            ),
                            const SizedBox(width: _legendGap),
                            Expanded(
                              child: CategoryLegend(
                                items: summary.legendItems,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      child: GradientButton(
                        label: 'View Details',
                        icon: Icons.arrow_forward,
                        onPressed: () => _openSummary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.homeIndex,
        onTap: (index) {
          if (index == AppBottomNav.addIndex) {
            _openAddTransaction(context);
          } else if (index == AppBottomNav.historyIndex) {
            _openHistory(context);
          } else if (index == AppBottomNav.summaryIndex) {
            _openSummary(context);
          }
        },
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(
              Icons.menu,
              size: 32,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName! 👋',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Track. Plan. Save. Grow.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
              size: 30,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
