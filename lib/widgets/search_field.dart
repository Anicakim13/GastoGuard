import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';

/// A white search box with a green outline and a magnifier icon.
/// [onChanged] is called every time the text changes.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.onChanged,
    this.hintText = 'Search Transactions',
  });

  final ValueChanged<String> onChanged;
  final String hintText;

  static OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppLayout.fieldRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      cursorColor: AppColors.primary,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 17),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 17),
        prefixIcon: const Icon(
          Icons.search,
          size: 28,
          color: AppColors.primaryDark,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: _border(AppColors.primaryDeep, 1),
        focusedBorder: _border(AppColors.primary, 2),
      ),
    );
  }
}
