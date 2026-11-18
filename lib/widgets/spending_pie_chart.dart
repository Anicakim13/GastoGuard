import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gastoguard/models/category_spending.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// A simple pie chart drawn with Flutter's own drawing tools (no packages).
///
/// The first slice starts at 12 o'clock and the slices go clockwise.
class SpendingPieChart extends StatelessWidget {
  const SpendingPieChart({
    super.key,
    required this.slices,
    required this.size,
  });

  /// The slices, in the order they are drawn.
  final List<CategorySpending> slices;

  /// Width and height of the chart.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PieChartPainter(slices)),
    );
  }
}

/// Does the actual drawing: one arc ("pie wedge") per slice.
class _PieChartPainter extends CustomPainter {
  _PieChartPainter(this.slices);

  final List<CategorySpending> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size; // the square we draw in
    final total = slices.fold<double>(0, (sum, slice) => sum + slice.percent);
    if (total <= 0) {
      // No spending yet: draw a plain white circle instead of nothing.
      canvas.drawOval(area, Paint()..color = AppColors.surface);
      return;
    }

    var startAngle = -math.pi / 2; // -90 degrees = 12 o'clock
    for (final slice in slices) {
      final sweepAngle = 2 * math.pi * (slice.percent / total);
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(area, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

/// The list next to the pie chart: a colored dot, the category name,
/// and its percentage.
class CategoryLegend extends StatelessWidget {
  const CategoryLegend({super.key, required this.items});

  final List<CategorySpending> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(width: 14, height: 14),
                ),
                const SizedBox(width: 8),
                // The name shrinks a little instead of overflowing.
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.percent.round()}%',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
