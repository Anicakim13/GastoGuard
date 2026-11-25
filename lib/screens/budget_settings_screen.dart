
import 'package:flutter/material.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/screens/history_screen.dart';
import 'package:gastoguard/screens/spending_summary_screen.dart';
import 'package:gastoguard/services/budget_settings.dart';
import 'package:gastoguard/services/budget_settings_scope.dart';
import 'package:gastoguard/services/budget_settings_store.dart';
import 'package:gastoguard/services/spending_summary.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';
import 'package:gastoguard/utils/amount_parser.dart';
import 'package:gastoguard/widgets/alert_switch_tile.dart';
import 'package:gastoguard/widgets/app_bottom_nav.dart';
import 'package:gastoguard/widgets/budget_amount_field.dart';
import 'package:gastoguard/widgets/form_section.dart';
import 'package:gastoguard/widgets/gradient_button.dart';
import 'package:gastoguard/widgets/pill_toggle.dart';

/// The Budget Settings screen.
///
/// Users can configure weekly and monthly budgets and notification alerts.
/// Settings are saved through BudgetSettingsStore when available.
class BudgetSettingsScreen extends StatefulWidget {
  const BudgetSettingsScreen({
    super.key,
    this.initialWeeklyLimit = SpendingSummary.weeklyBudgetLimit,
    this.initialMonthlyLimit = SpendingSummary.monthlyBudgetLimit,
  });

  final double initialWeeklyLimit;
  final double initialMonthlyLimit;

  @override
  State<BudgetSettingsScreen> createState() =>
      _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen> {
  late final BudgetSettingsStore? _budgetStore;

  late final Map<SummaryPeriod, double> _limits;

  SummaryPeriod _period = SummaryPeriod.monthly;

  late final List<bool> _alertOn;

  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  double get _limit => _limits[_period] ?? 0;

  @override
  void initState() {
    super.initState();

    _budgetStore = BudgetSettingsScope.maybeRead(context);

    _limits = {
      SummaryPeriod.weekly:
          _budgetStore?.weeklyLimit ?? widget.initialWeeklyLimit,
      SummaryPeriod.monthly:
          _budgetStore?.monthlyLimit ?? widget.initialMonthlyLimit,
    };

    _alertOn = [
      _budgetStore?.alert80Enabled ?? true,
      _budgetStore?.alert100Enabled ?? true,
    ];

    _controller = TextEditingController(
      text: formatBudgetField(_limit),
    );

    _focusNode.addListener(_showLimitInField);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showLimitInField() {
    if (_focusNode.hasFocus) {
      final text = editableBudgetText(_limit);

      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection(
          baseOffset: 0,
          extentOffset: text.length,
        ),
      );
    } else {
      _controller.text = formatBudgetField(_limit);
    }
  }

  void _onPeriodChanged(int index) {
    setState(() {
      _period = SummaryPeriod.values[index];
    });

    _showLimitInField();
  }

  void _onLimitTyped(String text) {
    setState(() {
      _limits[_period] = parseAmount(text) ?? 0;
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (_limit <= 0) {
      _showMessage('Enter a budget greater than zero');
      return;
    }

    try {
      if (_budgetStore != null) {
        await _budgetStore.saveSettings(
          weeklyLimit: _limits[SummaryPeriod.weekly]!,
          monthlyLimit: _limits[SummaryPeriod.monthly]!,
          alert80Enabled: _alertOn[0],
          alert100Enabled: _alertOn[1],
        );
      }

      if (!mounted) return;

      _showMessage('Budget settings saved');
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to save budget settings. Please try again.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxContentWidth,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sideMargin = constraints.maxWidth * 0.10;

                return Column(
                  children: [
                    const _Header(),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          sideMargin,
                          8,
                          sideMargin,
                          16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PillToggle(
                              labels: [
                                for (final p in SummaryPeriod.values)
                                  p.label,
                              ],
                              selectedIndex: _period.index,
                              onChanged: _onPeriodChanged,
                            ),
                            const SizedBox(height: 24),

                            FormSection(
                              label: 'Set Budget Limit',
                              child: BudgetAmountField(
                                controller: _controller,
                                focusNode: _focusNode,
                                onChanged: _onLimitTyped,
                              ),
                            ),
                            const SizedBox(height: 22),

                            FormSection(
                              label: 'Alerts',
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  for (var i = 0;
                                      i < budgetAlertLevels.length;
                                      i++) ...[
                                    if (i > 0)
                                      const SizedBox(height: 16),
                                    AlertSwitchTile(
                                      label: budgetAlertLevels[i]
                                          .labelFor(_limit),
                                      value: _alertOn[i],
                                      onChanged: (isOn) {
                                        setState(() {
                                          _alertOn[i] = isOn;
                                        });
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        sideMargin,
                        8,
                        sideMargin,
                        16,
                      ),
                      child: GradientButton(
                        label: 'Save Changes',
                        onPressed: _save,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),

      bottomNavigationBar: AppBottomNav(
        currentIndex: AppBottomNav.summaryIndex,
        onTap: (index) {
          if (index == AppBottomNav.homeIndex) {
            Navigator.of(context).popUntil(
              (route) => route.isFirst,
            );
          } else if (index == AppBottomNav.addIndex) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AddTransactionScreen(),
              ),
            );
          } else if (index == AppBottomNav.historyIndex) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const HistoryScreen(),
              ),
            );
          } else if (index == AppBottomNav.summaryIndex) {
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
}

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
              'Budget Settings',
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
