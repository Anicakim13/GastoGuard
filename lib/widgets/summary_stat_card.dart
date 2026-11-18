import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// A small card with an icon, a label, and an amount, for example
/// "Total Spent  ₱900.00". Used on the Spending Summary screen.
class SummaryStatCard extends StatelessWidget {
  const SummaryStatCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
    this.circleIcon = true,
  });

  /// Small title, for example "Total Spent".
  final String label;

  /// The amount, already formatted, for example "₱900.00".
  final String amount;

  final IconData icon;

  /// The color of the icon (or of the circle behind it).
  final Color iconColor;

  /// true = a white icon inside a colored circle; false = a plain colored icon.
  final bool circleIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textPrimary),
      ),
      child: Row(
        children: [
          if (circleIcon)
            DecoratedBox(
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Icon(icon, color: AppColors.textOnGreen, size: 20),
              ),
            )
          else
            Icon(icon, color: iconColor, size: 34),
          const SizedBox(width: 10),
          // Both texts shrink a little rather than wrapping or overflowing.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
