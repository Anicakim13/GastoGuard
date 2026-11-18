import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// A pill-shaped toggle with two (or more) options, like "Expense | Income".
///
/// The selected option sits on a green gradient pill that slides to the
/// chosen side. Reusable for "Weekly | Monthly" later.
class PillToggle extends StatelessWidget {
  const PillToggle({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  /// The option names, for example ['Expense', 'Income'].
  final List<String> labels;

  /// Position of the selected option (0 = first).
  final int selectedIndex;

  /// Called with the tapped option's position.
  final ValueChanged<int> onChanged;

  static const double _height = 40;

  @override
  Widget build(BuildContext context) {
    final count = labels.length;
    // The gradient pill is a little wider than one option so that it overlaps
    // the white track, like in the Canva design.
    final pillWidthFactor = math.min(1.0, 1 / count + 0.06);
    // -1.0 = far left, 1.0 = far right
    final pillAlignmentX =
        count > 1 ? -1.0 + 2.0 * selectedIndex / (count - 1) : 0.0;
    final radius = BorderRadius.circular(_height / 2);

    return SizedBox(
      height: _height,
      child: Stack(
        children: [
          // 1. White track with a thin black outline
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: radius,
                border: Border.all(color: AppColors.textPrimary, width: 1.5),
              ),
            ),
          ),
          // 2. Green gradient pill behind the selected option
          Positioned.fill(
            child: AnimatedAlign(
              alignment: Alignment(pillAlignmentX, 0),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: FractionallySizedBox(
                widthFactor: pillWidthFactor,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    borderRadius: radius,
                  ),
                ),
              ),
            ),
          ),
          // 3. The option names (these receive the taps)
          Positioned.fill(
            child: Row(
              children: [
                for (var i = 0; i < count; i++)
                  Expanded(
                    child: _ToggleOption(
                      text: labels[i],
                      selected: i == selectedIndex,
                      onTap: () => onChanged(i),
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

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selected ? AppColors.textOnGreen : AppColors.primaryDeep,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
