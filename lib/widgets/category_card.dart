import 'package:flutter/material.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// A selectable category: a white rounded tile with an outlined icon,
/// and the category name underneath.
///
/// The design only shows the normal look. When [selected], the outline gets
/// thicker, the tile gets a light tint of the category color, and the name
/// turns bold.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final TransactionCategory category;
  final bool selected;
  final VoidCallback onTap;

  /// Width / height of the tile (about 84 x 71 in the design).
  static const double _tileAspectRatio = 84 / 71;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: category.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: _tileAspectRatio,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: selected
                      ? Color.alphaBlend(
                          category.color.withAlpha(31),
                          AppColors.surface,
                        )
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: category.color,
                    width: selected ? 3 : 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 16,
                      offset: Offset(5, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    category.icon,
                    size: 40,
                    color: category.iconColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // The name shrinks a little rather than wrapping or overflowing.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                category.name,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
