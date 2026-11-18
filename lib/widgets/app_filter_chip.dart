import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// A rounded button used to filter a list ("All", "Income", "Expense").
/// The selected chip is green with white text; the others are white.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const double _height = 46;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: _height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(_height / 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(3, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.textOnGreen : AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
