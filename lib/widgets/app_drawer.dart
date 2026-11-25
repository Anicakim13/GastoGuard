import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// The side menu that slides in from the left of the Dashboard.
///
/// It shows the profile (picture, name, tagline) and five menu items.
/// Tapping an item closes the menu and then calls that item's callback, so
/// the screen that owns the menu decides what happens next.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.userName,
    this.tagline = 'Track. Smart. Spent Better',
    required this.onBudgetSettings,
    required this.onAbout,
    required this.onHelpAndSupport,
    required this.onDarkMode,
    required this.onDeleteData,
  });

  /// The name shown under the profile picture.
  final String userName;

  /// The small line under the name.
  final String tagline;

  final VoidCallback onBudgetSettings;
  final VoidCallback onAbout;
  final VoidCallback onHelpAndSupport;
  final VoidCallback onDarkMode;
  final VoidCallback onDeleteData;

  @override
  Widget build(BuildContext context) {
    // About two thirds of the screen, like the Canva design, but never too
    // narrow on a small phone or too wide in a big browser window.
    final width =
        (MediaQuery.sizeOf(context).width * 0.67).clamp(250.0, 300.0).toDouble();

    return Drawer(
      width: width,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent, // no color tint over the white
      shape: const RoundedRectangleBorder(), // square edge, like the design
      child: SafeArea(
        // Scrolls on very short screens, so nothing can overflow.
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              const _Avatar(),
              const SizedBox(height: 20),

              // Name and tagline shrink a little if they are very long.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    userName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    tagline,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              _DrawerItem(
                icon: Icons.settings_outlined,
                label: 'Budget Settings',
                onTap: onBudgetSettings,
              ),
              _DrawerItem(
                icon: Icons.info_outline,
                label: 'About GastoGuard',
                onTap: onAbout,
              ),
              _DrawerItem(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: onHelpAndSupport,
              ),
              _DrawerItem(
                icon: Icons.contrast,
                label: 'Dark Mode',
                onTap: onDarkMode,
              ),
              _DrawerItem(
                icon: Icons.delete_outline,
                label: 'Delete Data',
                onTap: onDeleteData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The round profile picture: a dark green circle with a light silhouette.
class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Profile picture',
      child: ClipOval(
        child: Container(
          width: 98,
          height: 98,
          color: AppColors.primaryDeep,
          // The icon is a little too big and sits low, so the circle cuts
          // off the shoulders, like in the design.
          alignment: const Alignment(0, 0.55),
          child: const Icon(
            Icons.person,
            size: 92,
            color: AppColors.background,
          ),
        ),
      ),
    );
  }
}

/// One menu row: an outlined icon and a bold label.
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(); // close the menu first
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 32, color: AppColors.textPrimary),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
