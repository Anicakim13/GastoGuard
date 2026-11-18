import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// A bold label with a form control underneath it.
/// Example: "Amount" above the amount field.
class FormSection extends StatelessWidget {
  const FormSection({super.key, required this.label, required this.child});

  /// The bold title, for example "Amount".
  final String label;

  /// The control shown under the title (a text field, date field, and so on).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
