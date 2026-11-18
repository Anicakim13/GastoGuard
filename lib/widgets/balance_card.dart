import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/utils/currency_formatter.dart';

/// The big green card at the top of the Dashboard.
///
/// Shows the remaining balance, a progress bar, the percentage left,
/// and the weekly budget.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.remaining,
    required this.progress,
    required this.weeklyBudget,
  });

  /// Money left (for example 850). Can be negative.
  final double remaining;

  /// How full the progress bar is, from 0.0 (empty) to 1.0 (full).
  /// The percentage next to the bar is this number times 100.
  final double progress;

  /// The weekly budget shown at the bottom of the card (for example 1000).
  final double weeklyBudget;

  /// Below this card width (narrow phones) the card uses a smaller wallet
  /// icon and slimmer side padding, so "Remaining Balance" keeps its size
  /// and stays on one line.
  static const double _compactBelowWidth = 300;

  @override
  Widget build(BuildContext context) {
    // Keep the bar inside 0%..100% even if a wrong number is passed in.
    final shownProgress = progress.clamp(0.0, 1.0).toDouble();
    final percentText = '${(shownProgress * 100).round()}%';

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < _compactBelowWidth;
        final sidePadding = compact ? 18.0 : 22.0;
        final walletSize = compact ? 44.0 : 60.0;

        return Container(
          padding: EdgeInsets.fromLTRB(sidePadding, 22, sidePadding, 18),
          decoration: BoxDecoration(
            gradient: AppColors.balanceCardGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + amount on the left, wallet icon on the right
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FittedBox keeps the title on one line; it only
                        // scales down if the space is truly too small.
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Remaining Balance',
                            style: TextStyle(
                              color: AppColors.textOnGreen,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formatPeso(remaining, withSpace: true),
                            style: const TextStyle(
                              color: AppColors.textOnGreen,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: walletSize,
                    color: AppColors.textOnGreen,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress bar + percentage
              Row(
                children: [
                  Expanded(flex: 5, child: _ProgressBar(value: shownProgress)),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        percentText,
                        style: const TextStyle(
                          color: AppColors.textOnGreen,
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                'Weekly Budget: ${formatPeso(weeklyBudget, withSpace: true)}',
                style: const TextStyle(
                  color: AppColors.textOnGreen,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A rounded progress bar: an outlined track with a light fill inside.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  /// Filled part of the bar, from 0.0 to 1.0.
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.progressBorder, width: 1.5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.progressFill,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
