
import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';

/// Shared bottom navigation for the GastoGuard screens.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  // Keep existing indexes unchanged.
  static const int homeIndex = 0;
  static const int addIndex = 1;
  static const int historyIndex = 2;
  static const int summaryIndex = 3;
  static const int settingsIndex = 4;

  // Visual order: Home, History, Add, Summary, Settings.
  static const List<_NavItem> _items = [
    _NavItem(
      index: homeIndex,
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      index: historyIndex,
      icon: Icons.history_rounded,
      label: 'History',
    ),
    _NavItem(
      index: addIndex,
      icon: Icons.add_rounded,
      label: 'Add',
      isAdd: true,
    ),
    _NavItem(
      index: summaryIndex,
      icon: Icons.bar_chart_rounded,
      label: 'Summary',
    ),
    _NavItem(
      index: settingsIndex,
      icon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.navDivider),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 8, 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (final item in _items)
                    Expanded(
                      child: _NavButton(
                        item: item,
                        selected: item.index == currentIndex,
                        onTap: () => onTap(item.index),
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

class _NavItem {
  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    this.isAdd = false,
  });

  final int index;
  final IconData icon;
  final String label;
  final bool isAdd;
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
    if (item.isAdd) {
      return _buildAddButton();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 27,
              color: selected
                  ? AppColors.primary
                  : AppColors.textPrimary,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? AppColors.primary
                    : AppColors.textPrimary,
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Transform.translate(
        offset: const Offset(0, -10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.textOnGreen,
                size: 34,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Add',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
