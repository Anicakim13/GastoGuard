import 'package:flutter/material.dart';
import 'package:gastoguard/services/help_faqs.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';

/// A question that opens to show its answer when tapped, and closes when
/// tapped again. It is a white rounded card with a thin outline, like the
/// other cards in GastoGuard.
class FaqTile extends StatelessWidget {
  const FaqTile({super.key, required this.entry});

  final FaqEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Clips the tap ripple to the rounded corners.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppLayout.fieldRadius),
        border: Border.all(color: AppColors.textPrimary),
      ),
      child: ExpansionTile(
        // No extra lines above and below the tile.
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(entry.icon, color: AppColors.primary),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textPrimary,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(
          entry.question,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        children: [
          Text(
            entry.answer,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
