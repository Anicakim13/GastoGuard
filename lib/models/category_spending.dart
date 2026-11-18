import 'package:flutter/material.dart';

/// One category's share of the spending (used by the pie chart and legend).
///
/// Example: Food is 40% of all spending and is shown in orange.
class CategorySpending {
  const CategorySpending({
    required this.name,
    required this.percent,
    required this.color,
  });

  /// Category name shown in the legend, for example "Food".
  final String name;

  /// Share of the total, from 0 to 100.
  final double percent;

  /// Color of the pie slice and the legend dot.
  final Color color;
}
