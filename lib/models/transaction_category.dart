import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// One spending category: its name, icon, and colors.
///
/// The six categories from the design are listed in [TransactionCategory.all].
class TransactionCategory {
  const TransactionCategory({
    required this.name,
    required this.icon,
    required this.color,
    Color? iconColor,
  }) : iconColor = iconColor ?? color;

  /// Name shown under the card, for example "Food".
  final String name;

  /// Icon shown on the card.
  final IconData icon;

  /// Main color: card outline, selection highlight.
  final Color color;

  /// Color of the icon itself (usually the same as [color]).
  final Color iconColor;

  static const TransactionCategory food = TransactionCategory(
    name: 'Food',
    icon: Icons.restaurant,
    color: AppColors.food,
  );
  static const TransactionCategory transportation = TransactionCategory(
    name: 'Transportation',
    icon: Icons.directions_bus,
    color: AppColors.transportation,
  );
  static const TransactionCategory data = TransactionCategory(
    name: 'Data',
    icon: Icons.wifi,
    color: AppColors.data,
    iconColor: AppColors.dataIcon,
  );
  static const TransactionCategory schoolSupplies = TransactionCategory(
    name: 'School Supplies',
    icon: Icons.book,
    color: AppColors.schoolSupplies,
    iconColor: AppColors.schoolSuppliesIcon,
  );
  static const TransactionCategory entertainment = TransactionCategory(
    name: 'Entertainment',
    icon: Icons.sports_esports,
    color: AppColors.entertainment,
  );
  static const TransactionCategory others = TransactionCategory(
    name: 'Others',
    icon: Icons.more_horiz,
    color: AppColors.others,
  );

  /// All categories, in the order shown in the design.
  static const List<TransactionCategory> all = [
    food,
    transportation,
    data,
    schoolSupplies,
    entertainment,
    others,
  ];
}
