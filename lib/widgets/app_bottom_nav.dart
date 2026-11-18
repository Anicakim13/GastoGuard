import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';

/// The bottom navigation bar: Home, Add, History, Summary.
///
/// The selected item's icon is green. Tapping an item calls [onTap] with the
/// item's position (0 = Home, 1 = Add, 2 = History, 3 = Summary).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Which item is selected.
  final int currentIndex;

  /// Called when an item is tapped.
  final ValueChanged<int> onTap;

  // Positions of the items below. Screens use these names instead of bare
  // numbers. Keep them in the same order as _items.
  static const int homeIndex = 0;
  static const int addIndex = 1;
  static const int historyIndex = 2;
  static const int summaryIndex = 3;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.add_circle_outline, label: 'Add'),
    _NavItem(icon: Icons.history, label: 'History'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Summary'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // The thin gray line above the bar
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.navDivider)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            // Same maximum width as the Dashboard content (wide screens / web).
            constraints:
                const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    for (var i = 0; i < _items.length; i++)
                      Expanded(
                        child: _NavButton(
                          item: _items[i],
                          selected: i == currentIndex,
                          onTap: () => onTap(i),
                        ),
                      ),
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

/// The icon and label of one navigation item.
class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 34,
              color: selected ? AppColors.primary : AppColors.textPrimary,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
