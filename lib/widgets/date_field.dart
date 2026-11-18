import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';
import 'package:gastoguard/utils/date_formatter.dart';

/// A white field that shows a date next to a calendar icon.
/// Tapping it calls [onTap] (the screen opens a date picker).
class DateField extends StatelessWidget {
  const DateField({super.key, required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppLayout.fieldRadius),
        side: const BorderSide(color: AppColors.textPrimary),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 30,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  formatShortDate(date),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
