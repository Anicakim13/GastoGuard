import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';

/// A white rounded row with a text and a green on/off switch, for example
/// "Notify at 80% (₱800.00)". Tapping anywhere on the row flips the switch.
class AlertSwitchTile extends StatelessWidget {
  const AlertSwitchTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// The text on the left.
  final String label;

  /// true = switched on.
  final bool value;

  /// Called with the new value when the row or the switch is tapped.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    // MergeSemantics lets a screen reader read the text and the switch
    // together as one item.
    return MergeSemantics(
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.fieldRadius),
          side: const BorderSide(color: AppColors.textPrimary),
        ),
        child: InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
            child: SizedBox(
              height: 54,
              child: Row(
                children: [
                  // The text shrinks a little rather than wrapping.
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // The standard switch is bigger than the one in the design,
                  // so it is scaled down to about 40 x 24.
                  SizedBox(
                    width: 40,
                    height: 24,
                    child: FittedBox(
                      child: Switch(
                        value: value,
                        onChanged: onChanged,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: AppColors.textOnGreen,
                        activeTrackColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
