
import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// A wide, rounded button with the green gradient from the GastoGuard design.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  static const double _height = 58;
  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(_radius);

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: borderRadius,
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: borderRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textOnGreen,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        icon,
                        color: AppColors.textOnGreen,
                        size: 26,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
