import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/screens/history_screen.dart';
import 'package:gastoguard/screens/spending_summary_screen.dart';
import 'package:gastoguard/services/dashboard_summary.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';
import 'package:gastoguard/utils/currency_formatter.dart';
import 'package:gastoguard/widgets/app_bottom_nav.dart';
import 'package:gastoguard/widgets/balance_card.dart';
import 'package:gastoguard/widgets/gradient_button.dart';
import 'package:gastoguard/widgets/spending_pie_chart.dart';
import 'package:gastoguard/widgets/stat_card.dart';

/// The Home / Dashboard screen.
///
/// From top to bottom: greeting, balance card, Income and Spent cards,
/// "Spending by Category" pie chart with legend, "View Details" button,
/// and the bottom navigation bar.
///
/// The balance, Income, Spent, and pie chart are worked out from the shared
/// transaction list (see [DashboardSummary]), so they update by themselves
/// whenever a transaction is added. The greeting name and the weekly budget
/// are still SAMPLE VALUES from the Canva design.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // ---------------------------------------------------------------------------
  // SAMPLE VALUES (from the Canva design)
  // ---------------------------------------------------------------------------
  // There is no user profile or Budget Settings screen yet, so the name and
  // the weekly budget are still fixed sample values.
  static const String _userName = 'Renz';
  static const double _weeklyBudget = 1000;

  // ---------------------------------------------------------------------------
  // LAYOUT NUMBERS
  // ---------------------------------------------------------------------------
  static const double _cardMargin = 22; // space left/right of the cards
  static const double _sectionMargin = 33; // space left/right of the chart area
  static const double _legendGap = 12; // space between the pie and the legend
  static const double _legendMinWidth = 120; // room for "Transport" + "30%"

  /// Opens the Add Transaction screen on top of this Dashboard.
  ///
  /// "push" keeps the Dashboard underneath. The back arrow on the Add
  /// Transaction screen then just closes that screen and returns here, so
  /// there is never a second copy of the Dashboard.
  void _openAddTransaction(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddTransactionScreen()),
    );
  }

  /// Opens the Transaction History screen on top of this Dashboard.
  /// Like Add Transaction, it is pushed on top, so going back returns to this
  /// same Dashboard.
  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
    );
  }

  /// Opens the Spending Summary screen on top of this Dashboard.
  /// Going back returns to this same Dashboard.
  void _openSummary(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SpendingSummaryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The numbers come from the shared transaction list. Asking for it here
    // makes the Dashboard redraw whenever a transaction is added. Without a
    // shared list (for example in the preview file) the sample values from
    // the Canva design are shown instead.
    final store = TransactionScope.maybeOf(context);
    final summary = store == null
        ? DashboardSummary.sample
        : DashboardSummary.fromTransactions(store.transactions);

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            // Scrolls on small screens so nothing can overflow.
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Greeting row
                  const _DashboardHeader(userName: _userName),
                  const SizedBox(height: 12),

                  // 2. Balance card
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: _cardMargin),
                    child: BalanceCard(
                      remaining: summary.balance,
                      progress: summary.balanceShare,
                      weeklyBudget: _weeklyBudget,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Income and Spent cards, side by side
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: _cardMargin),
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

                  // 4. Spending by Category: title, pie chart, legend
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: _sectionMargin),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: _sectionMargin),
                    // LayoutBuilder tells us how wide the area is. The pie
                    // takes about 58% of it, but never so much that the legend
                    // is squeezed: the legend always keeps _legendMinWidth, so
                    // its labels stay at full size even on narrow phones.
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final pieSize = math.max(
                          96.0,
                          math.min(
                            constraints.maxWidth * 0.58,
                            constraints.maxWidth - _legendGap - _legendMinWidth,
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
                              child: CategoryLegend(items: summary.legendItems),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. "View Details" button (80% of the width, centered)
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

      // 6. Bottom navigation bar (Home is selected). "Add" opens the Add
      //    Transaction screen, "History" opens the Transaction History
      //    screen, and "Summary" opens the Spending Summary screen.
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

/// The top row: menu icon, greeting, and notification bell.
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
            onPressed: () {
              // TODO: open the side menu later.
            },
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
            onPressed: () {
              // TODO: open notifications later.
            },
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
