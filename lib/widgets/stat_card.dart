import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// A small white card with a colored round icon, a label, and an amount.
/// Used for "Income" and "Spent" on the Dashboard.
///
/// On normal phones the icon sits to the left of the text (like the design).
/// On narrow phones the card is too small for that, so the icon and label
/// share the first line and the amount gets the full card width underneath.
/// That way the amount keeps its size instead of being shrunk.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.borderColor,
  });

  /// Small title, for example "Income".
  final String label;

  /// The amount, already formatted, for example "₱1,000.00".
  final String amount;

  /// Icon drawn in white inside the colored circle.
  final IconData icon;

  /// Color of the circle behind the icon.
  final Color iconColor;

  /// Color of the thin outline around the card.
  final Color borderColor;

  /// Below this card width the stacked layout is used. A side-by-side card
  /// needs about 155 px so that an amount like "₱1,000.00" fits at full size.
  static const double _stackedBelowWidth = 155;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < _stackedBelowWidth;

        // The three pieces of the card. They are the same in both layouts;
        // only the way they are arranged changes.
        final iconCircle = DecoratedBox(
          decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, color: AppColors.textOnGreen, size: 22),
          ),
        );
        final labelText = Text(
          label,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        );
        // The amount still scales down as a last resort (for example when
        // the phone's text size is set very large).
        final amountText = FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            amount,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

        final Widget content;
        if (stacked) {
          // Narrow phones: [icon] label
          //                amount
          content = Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  iconCircle,
                  const SizedBox(width: 8),
                  Expanded(child: labelText),
                ],
              ),
              const SizedBox(height: 6),
              amountText,
            ],
          );
        } else {
          // Normal phones: [icon]  label
          //                        amount
          content = Row(
            children: [
              iconCircle,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    labelText,
                    const SizedBox(height: 2),
                    amountText,
                  ],
                ),
              ),
            ],
          );
        }

        return Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: EdgeInsets.symmetric(
            horizontal: stacked ? 12 : 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardTint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: content,
        );
      },
    );
  }
}
