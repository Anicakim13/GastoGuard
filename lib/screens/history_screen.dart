import 'package:flutter/material.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/screens/spending_summary_screen.dart';
import 'package:gastoguard/services/transaction_filter.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/services/transaction_store.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';
import 'package:gastoguard/utils/date_formatter.dart';
import 'package:gastoguard/widgets/app_bottom_nav.dart';
import 'package:gastoguard/widgets/app_dropdown.dart';
import 'package:gastoguard/widgets/app_filter_chip.dart';
import 'package:gastoguard/widgets/search_field.dart';
import 'package:gastoguard/widgets/transaction_tile.dart';

/// The Transaction History screen.
///
/// It shows the transactions from the shared [TransactionStore], so anything
/// saved on the Add Transaction screen appears here by itself. (The store
/// starts with SAMPLE transactions; nothing is stored permanently yet.)
///
/// Search, the All / Income / Expense chips, and both dropdowns really
/// filter the list.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.today});

  /// What "today" is. It decides what "This Month" means and when the demo
  /// transactions happened. If left out, the real date is used.
  /// (Tests pass a fixed date so their results never change.)
  final DateTime? today;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Choices for the category dropdown. null means "All Categories".
  static const List<TransactionCategory?> _categoryOptions = [
    null,
    ...TransactionCategory.all,
  ];

  late final DateTime _today;

  // Only used when there is no shared store above this screen (for example
  // in the preview file): a private store with the sample transactions.
  late final TransactionStore _fallbackStore =
      TransactionStore.withDemoData(_today);

  // What the person has chosen (all local; nothing is saved)
  String _query = '';
  TypeFilter _type = TypeFilter.all;
  TransactionCategory? _category;
  HistoryPeriod _period = HistoryPeriod.thisMonth;

  @override
  void initState() {
    super.initState();
    _today = widget.today ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    // The shared store. Asking for it here makes this screen redraw
    // whenever a transaction is added.
    final store = TransactionScope.maybeOf(context) ?? _fallbackStore;

    // Apply the search, chips, and dropdowns, then group by month.
    final groups = groupByMonth(
      filterTransactions(
        store.transactions,
        today: _today,
        query: _query,
        type: _type,
        category: _category,
        period: _period,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sideMargin = constraints.maxWidth * 0.10;

                return Column(
                  children: [
                    const _Header(),
                    // Everything below the header scrolls together, so nothing
                    // overflows when the keyboard is open or the screen is small.
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(sideMargin, 8, sideMargin, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SearchField(
                              onChanged: (text) => setState(() => _query = text),
                            ),
                            const SizedBox(height: 14),
                            _buildTypeChips(),
                            const SizedBox(height: 14),
                            _buildDropdowns(),
                            const SizedBox(height: 18),

                            if (groups.isEmpty)
                              const _EmptyMessage()
                            else
                              for (final group in groups) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4, bottom: 8),
                                  child: Text(
                                    formatMonthYear(group.month),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                for (final transaction in group.transactions)
                                  TransactionTile(
                                    key: ValueKey(transaction.id),
                                    transaction: transaction,
                                  ),
                              ],
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

      // The same bottom bar as the Dashboard, with History selected.
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.historyIndex,
        onTap: (index) {
          if (index == AppBottomNav.homeIndex) {
            // Go back to the Dashboard, the first screen of the app.
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == AppBottomNav.addIndex) {
            // Add Transaction opens on top, so its back arrow returns here.
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AddTransactionScreen(),
              ),
            );
          } else if (index == AppBottomNav.summaryIndex) {
            // Swap this screen for the Spending Summary, so its back arrow
            // still goes straight to the Dashboard.
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const SpendingSummaryScreen(),
              ),
            );
          }
        },
      ),
    );
  }

  /// The three chips: All, Income, Expense.
  Widget _buildTypeChips() {
    return Row(
      children: [
        for (var i = 0; i < TypeFilter.values.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: AppFilterChip(
              label: TypeFilter.values[i].label,
              selected: _type == TypeFilter.values[i],
              onTap: () => setState(() => _type = TypeFilter.values[i]),
            ),
          ),
        ],
      ],
    );
  }

  /// The category and month dropdowns: side by side, or one above the other
  /// on very narrow phones.
  Widget _buildDropdowns() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final categoryDropdown = AppDropdown<TransactionCategory?>(
          value: _category,
          items: _categoryOptions,
          labelOf: (category) => category?.name ?? 'All Categories',
          onChanged: (category) => setState(() => _category = category),
        );
        final periodDropdown = AppDropdown<HistoryPeriod>(
          value: _period,
          items: HistoryPeriod.values,
          labelOf: (period) => period.label,
          onChanged: (period) => setState(() => _period = period),
        );

        if (constraints.maxWidth < 260) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              categoryDropdown,
              const SizedBox(height: 12),
              periodDropdown,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: categoryDropdown),
            const SizedBox(width: 12),
            Expanded(child: periodDropdown),
          ],
        );
      },
    );
  }
}

/// The top row: back arrow and the centered title.
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
              // Closes this screen and reveals the Dashboard underneath, so
              // there is never a second copy of the Dashboard.
              Navigator.of(context).maybePop();
            },
            icon: const Icon(
              Icons.arrow_back,
              size: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const Expanded(
            child: Text(
              'Transaction History',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Same width as the back button, so the title stays centered.
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// Shown when no transaction matches the search and filters.
class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'No transactions found',
          style: TextStyle(color: AppColors.textHint, fontSize: 16),
        ),
      ),
    );
  }
}
