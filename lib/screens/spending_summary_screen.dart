
import 'package:flutter/material.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/screens/history_screen.dart';
import 'package:gastoguard/services/budget_settings_scope.dart';
import 'package:gastoguard/services/spending_summary.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/services/transaction_store.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';
import 'package:gastoguard/utils/currency_formatter.dart';
import 'package:gastoguard/widgets/app_bottom_nav.dart';
import 'package:gastoguard/widgets/category_icon_tile.dart';
import 'package:gastoguard/widgets/pill_toggle.dart';
import 'package:gastoguard/widgets/share_progress_bar.dart';
import 'package:gastoguard/widgets/spending_bar_chart.dart';
import 'package:gastoguard/widgets/summary_stat_card.dart';

/// The Spending Summary screen.
///
/// It is worked out from the shared transaction list (only expenses count),
/// so it updates whenever a transaction is added. The Weekly and Monthly
/// tabs use the corresponding saved budget settings.
class SpendingSummaryScreen extends StatefulWidget {
  const SpendingSummaryScreen({super.key, this.today});

  /// What "today" is. It decides which week and month are "this" week and
  /// month. If left out, the real date is used. (Tests pass a fixed date.)
  final DateTime? today;

  @override
  State<SpendingSummaryScreen> createState() => _SpendingSummaryScreenState();
}

class _SpendingSummaryScreenState extends State<SpendingSummaryScreen> {
  late final DateTime _today;

  // Only used when there is no shared store above this screen.
  late final TransactionStore _fallbackStore =
      TransactionStore.withDemoData(_today);

  // The Canva design shows Monthly selected.
  SummaryPeriod _period = SummaryPeriod.monthly;

  @override
  void initState() {
    super.initState();
    _today = widget.today ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    // Shared transaction and budget stores.
    // maybeOf makes the screen rebuild when either store changes.
    final store = TransactionScope.maybeOf(context) ?? _fallbackStore;
    final budgetStore = BudgetSettingsScope.maybeOf(context);

    final budgetLimit = _period == SummaryPeriod.weekly
        ? budgetStore?.weeklyLimit ?? SpendingSummary.weeklyBudgetLimit
        : budgetStore?.monthlyLimit ?? SpendingSummary.monthlyBudgetLimit;

    final summary = SpendingSummary.fromTransactions(
      store.transactions,
      period: _period,
      today: _today,
      budgetLimit: budgetLimit,
    );

    // The chart is taller on tall screens, but never too small or too big.
    final plotHeight =
        (MediaQuery.sizeOf(context).height * 0.32).clamp(150.0, 300.0).toDouble();

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // The design has about 10% empty space at the sides, and the
                // chart is a little wider (about 5%).
                final sideMargin = constraints.maxWidth * 0.10;
                final chartMargin = constraints.maxWidth * 0.05;

                return Column(
                  children: [
                    const _Header(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Weekly | Monthly
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: sideMargin),
                              child: PillToggle(
                                labels: [
                                  for (final p in SummaryPeriod.values) p.label,
                                ],
                                selectedIndex: _period.index,
                                onChanged: (index) => setState(
                                  () => _period = SummaryPeriod.values[index],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // The bar chart
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: chartMargin),
                              child: SpendingBarChart(
                                labels: summary.barLabels,
                                values: summary.barValues,
                                axisMax: summary.axisMax,
                                plotHeight: plotHeight,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Total Spent | Budget Limit
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: sideMargin),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SummaryStatCard(
                                      label: 'Total Spent',
                                      amount: formatPeso(summary.totalSpent),
                                      icon: Icons.arrow_downward_rounded,
                                      iconColor: AppColors.expense,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: SummaryStatCard(
                                      label: 'Budget Limit',
                                      amount: formatPeso(summary.budgetLimit),
                                      icon: Icons.track_changes,
                                      iconColor: AppColors.food,
                                      circleIcon: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Top Category
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: sideMargin),
                              child: const Text(
                                'Top Category',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: sideMargin),
                              child: _TopCategoryCard(
                                topCategory: summary.topCategory,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),

      // The same bottom bar as the other screens, with Summary selected.
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.summaryIndex,
        onTap: (index) {
          if (index == AppBottomNav.homeIndex) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == AppBottomNav.addIndex) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AddTransactionScreen(),
              ),
            );
          } else if (index == AppBottomNav.historyIndex) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
            );
          }
        },
      ),
    );
  }
}

/// The top row: back arrow and the screen title.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            icon: const Icon(
              Icons.arrow_back,
              size: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Spending Summary',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The white card under "Top Category".
class _TopCategoryCard extends StatelessWidget {
  const _TopCategoryCard({required this.topCategory});

  final TopCategory? topCategory;

  @override
  Widget build(BuildContext context) {
    final top = topCategory;

    return Container(
      constraints: const BoxConstraints(minHeight: 79),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textPrimary),
      ),
      child: top == null
          ? const Center(
              child: Text(
                'No expenses yet',
                style: TextStyle(color: AppColors.textHint, fontSize: 16),
              ),
            )
          : Row(
              children: [
                CategoryIconTile(
                  category: top.category,
                  width: 67,
                  height: 57,
                  showShadow: false,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              top.category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${formatPeso(top.amount)} '
                                '(${(top.share * 100).round()}%)',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ShareProgressBar(value: top.share),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
