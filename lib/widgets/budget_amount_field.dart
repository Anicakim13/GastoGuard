import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';

/// The big white field where the budget amount is typed: a bold "₱" followed
/// by the bold amount. Only digits and a decimal point with up to two decimals
/// can be typed.
class BudgetAmountField extends StatelessWidget {
  const BudgetAmountField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;

  /// Lets the screen know when the field is tapped into or left.
  final FocusNode focusNode;

  /// Called every time the text changes.
  final ValueChanged<String> onChanged;

  static const TextStyle _textStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppLayout.fieldRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      style: _textStyle,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        // prefixIcon (unlike prefixText) is always visible.
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 20, right: 8),
          child: Text('₱', style: _textStyle),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.fromLTRB(0, 16, 20, 16),
        enabledBorder: _border(AppColors.textPrimary, 1),
        focusedBorder: _border(AppColors.primary, 2),
      ),
    );
  }
}
