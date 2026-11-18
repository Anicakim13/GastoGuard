import 'package:flutter/material.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// A white rounded tile with the category's icon, an outline in the
/// category color, and a soft shadow (used in the transaction list).
class CategoryIconTile extends StatelessWidget {
  const CategoryIconTile({
    super.key,
    required this.category,
    this.width = 80,
    this.height = 68,
    this.showShadow = true,
  });

  final TransactionCategory category;
  final double width;
  final double height;

  /// Set to false for a flat tile without the soft shadow.
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: category.color, width: 1.2),
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 12,
                  offset: Offset(4, 4),
                ),
              ]
            : null,
      ),
      child: Icon(category.icon, size: 38, color: category.iconColor),
    );
  }
}
