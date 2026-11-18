import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// A rounded bar with a white track, a green outline, and a green fill.
/// It shows how big a part [value] is of the whole (0.4 = 40%).
class ShareProgressBar extends StatelessWidget {
  const ShareProgressBar({super.key, required this.value});

  /// The filled part of the bar, from 0.0 to 1.0.
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0).toDouble(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
