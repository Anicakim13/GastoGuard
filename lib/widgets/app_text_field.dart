import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';

/// A white, rounded text field with a thin black outline (the style used
/// for Amount and Note). Turns green when you tap into it.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.prefixText,
    this.keyboardType,
    this.inputFormatters,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;

  /// Gray text shown while the field is empty, for example "0.00".
  final String? hintText;

  /// Text always shown before the input, for example "₱".
  final String? prefixText;

  final TextInputType? keyboardType;

  /// Rules for what can be typed (for example numbers only).
  final List<TextInputFormatter>? inputFormatters;

  final int minLines;
  final int maxLines;

  static const TextStyle _textStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
  );

  static OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppLayout.fieldRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPrefix = prefixText != null;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
      style: _textStyle,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: _textStyle.copyWith(color: AppColors.textHint),
        // prefixIcon (unlike prefixText) is visible even before you tap in.
        prefixIcon: hasPrefix
            ? Padding(
                padding: const EdgeInsets.only(left: 20, right: 8),
                child: Text(prefixText!, style: _textStyle),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.fromLTRB(hasPrefix ? 0 : 20, 16, 20, 16),
        enabledBorder: _border(AppColors.textPrimary, 1),
        focusedBorder: _border(AppColors.primary, 2),
      ),
    );
  }
}
