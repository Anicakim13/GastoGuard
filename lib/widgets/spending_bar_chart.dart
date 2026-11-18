import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/utils/currency_formatter.dart';

/// A simple bar chart drawn with Flutter's own tools (no packages).
///
/// It shows one dark green bar for each of the [values], with the [labels]
/// underneath, and a vertical axis from 0 up to [axisMax] with grid lines.
class SpendingBarChart extends StatelessWidget {
  const SpendingBarChart({
    super.key,
    required this.labels,
    required this.values,
    required this.axisMax,
    this.plotHeight = 240,
  });

  /// The name under each bar (same length as [values]).
  final List<String> labels;

  /// The height of each bar, in pesos.
  final List<double> values;

  /// The value at the top of the vertical axis.
  final double axisMax;

  /// The height of the chart area, not counting the labels.
  final double plotHeight;

  static const int _steps = 5; // 5 steps = 6 grid lines (0 to the top)
  static const double _topPadding = 8; // room for the top axis label
  static const double _axisWidth = 40;
  static const double _labelSize = 12;

  @override
  Widget build(BuildContext context) {
    // A sentence for screen readers, for example "Mon ₱0.00, Tue ₱50.00".
    final description = [
      for (var i = 0; i < values.length; i++)
        '${labels[i]} ${formatPeso(values[i])}',
    ].join(', ');

    return Semantics(
      label: 'Spending bar chart. $description',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The numbers on the left (0, 200, 400, ...), each one level with
          // its grid line.
          SizedBox(
            width: _axisWidth,
            height: plotHeight + 2 * _topPadding,
            child: Stack(
              children: [
                for (var i = 0; i <= _steps; i++)
                  Positioned(
                    right: 4,
                    top: _topPadding +
                        plotHeight * (1 - i / _steps) -
                        _labelSize * 0.65,
                    // A long number (like 25,000) shrinks a little to fit.
                    child: SizedBox(
                      width: _axisWidth - 4,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatWholeNumber(axisMax * i / _steps),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: _labelSize,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // The grid lines and bars, with the names underneath.
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: _topPadding),
                SizedBox(
                  height: plotHeight,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _BarsPainter(values: values, axisMax: axisMax),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final label in labels)
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: _labelSize,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws the horizontal grid lines and the bars.
class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.values, required this.axisMax});

  final List<double> values;
  final double axisMax;

  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines, from the top (axisMax) down to the bottom (0).
    final linePaint = Paint()
      ..color = AppColors.chartGridLine
      ..strokeWidth = 1;
    for (var i = 0; i <= SpendingBarChart._steps; i++) {
      final y = size.height * i / SpendingBarChart._steps;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    if (values.isEmpty || axisMax <= 0) return;

    // Each bar sits in its own slot and fills about 86% of it.
    final slotWidth = size.width / values.length;
    final barWidth = slotWidth * 0.86;
    final barPaint = Paint()..color = AppColors.primaryDeep;

    for (var i = 0; i < values.length; i++) {
      final barHeight =
          size.height * (values[i] / axisMax).clamp(0.0, 1.0).toDouble();
      if (barHeight <= 0) continue;

      final left = slotWidth * i + (slotWidth - barWidth) / 2;
      final bar = RRect.fromLTRBAndCorners(
        left,
        size.height - barHeight,
        left + barWidth,
        size.height,
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(bar, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) {
    return oldDelegate.axisMax != axisMax ||
        !listEquals(oldDelegate.values, values);
  }
}
