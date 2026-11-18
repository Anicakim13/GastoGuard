import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';

/// A white dropdown with a black outline and a down arrow.
///
/// It works with any kind of value ([T]): text, a category, an enum...
/// [labelOf] turns a value into the text that is shown.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  /// The currently selected value.
  final T value;

  /// All the choices.
  final List<T> items;

  /// Turns a value into the text shown for it.
  final String Function(T) labelOf;

  /// Called when a different choice is picked.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppLayout.fieldRadius),
        border: Border.all(color: AppColors.textPrimary),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textPrimary,
          ),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(AppLayout.fieldRadius),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          // The shown choice shrinks a little instead of being cut off.
          selectedItemBuilder: (context) => [
            for (final item in items)
              Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(labelOf(item)),
                ),
              ),
          ],
          items: [
            for (final item in items)
              DropdownMenuItem<T>(value: item, child: Text(labelOf(item))),
          ],
          onChanged: (picked) => onChanged(picked as T),
        ),
      ),
    );
  }
}
