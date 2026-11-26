
import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// The side menu that slides in from the left of the Dashboard.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.userName,
    this.tagline = 'Track. Smart. Spent Better',
    this.onEditProfile,
    required this.onBudgetSettings,
    required this.onAbout,
    required this.onHelpAndSupport,
    required this.onDarkMode,
    required this.onDeleteData,
  });

  final String userName;
  final String tagline;

  final VoidCallback? onEditProfile;
  final VoidCallback onBudgetSettings;
  final VoidCallback onAbout;
  final VoidCallback onHelpAndSupport;
  final VoidCallback onDarkMode;
  final VoidCallback onDeleteData;

  @override
  Widget build(BuildContext context) {
    final width =
        (MediaQuery.sizeOf(context).width * 0.67)
            .clamp(250.0, 300.0)
            .toDouble();

    return Drawer(
      width: width,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              const _Avatar(),
              const SizedBox(height: 20),

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
              const SizedBox(height: 32),

              _DrawerItem(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: onEditProfile ?? () {},
              ),
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
        Navigator.of(context).pop();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 36,
          vertical: 15,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.textPrimary,
            ),
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
