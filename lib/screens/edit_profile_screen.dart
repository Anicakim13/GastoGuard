
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastoguard/services/profile_settings_scope.dart';
import 'package:gastoguard/services/profile_settings_store.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';
import 'package:gastoguard/widgets/form_section.dart';
import 'package:gastoguard/widgets/gradient_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileSettingsStore? _profileStore;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();

    _profileStore = ProfileSettingsScope.maybeRead(context);

    _nameController = TextEditingController(
      text: _profileStore?.displayName ?? 'User',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter your display name.');
      return;
    }

    if (name.length > 30) {
      _showMessage('Display name cannot exceed 30 characters.');
      return;
    }

    if (_profileStore == null) {
      _showMessage('Unable to access profile settings.');
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      await _profileStore.saveDisplayName(name);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.fromLTRB(16, 0, 16, 90),
          ),
        );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      _showMessage('Unable to save profile. Please try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxContentWidth,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sideMargin = constraints.maxWidth * 0.10;

                return Column(
                  children: [
                    const _Header(),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          sideMargin,
                          24,
                          sideMargin,
                          16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: AppColors.primaryDeep,
                                child: Icon(
                                  Icons.person,
                                  size: 64,
                                  color: AppColors.background,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            FormSection(
                              label: 'Display Name',
                              child: TextField(
                                controller: _nameController,
                                maxLength: 30,
                                maxLengthEnforcement:
                                    MaxLengthEnforcement.enforced,
                                textCapitalization:
                                    TextCapitalization.words,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _save(),
                                decoration: InputDecoration(
                                  hintText: 'Enter your name',
                                  counterText: '',
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: AppColors.textPrimary
                                          .withOpacity(0.15),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: AppColors.textPrimary
                                          .withOpacity(0.15),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: AppColors.primaryDark,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This name will appear on your Dashboard '
                              'and profile menu.',
                              style: TextStyle(
                                color: AppColors.textPrimary
                                    .withOpacity(0.65),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        sideMargin,
                        8,
                        sideMargin,
                        16,
                      ),
                      child: GradientButton(
                        label: 'Save Changes',
                        onPressed: _save,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back,
              size: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Edit Profile',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
