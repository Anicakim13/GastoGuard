import 'package:flutter/material.dart';
import 'package:gastoguard/services/help_faqs.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';
import 'package:gastoguard/widgets/faq_tile.dart';
import 'package:gastoguard/widgets/form_section.dart';
import 'package:gastoguard/widgets/screen_header.dart';

/// The Help & Support screen: frequently asked questions that open when
/// tapped, and a Contact Support section.
///
/// The Contact Support section is only a PLACEHOLDER. GastoGuard has no
/// official support contact yet, so none is shown (and none is invented).
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sideMargin = constraints.maxWidth * 0.10;

                return Column(
                  children: [
                    const ScreenHeader(title: 'Help & Support'),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(sideMargin, 8, sideMargin, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 4, right: 4),
                              child: Text(
                                'Quick answers to common questions about '
                                'using GastoGuard. Tap a question to see the '
                                'answer.',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            FormSection(
                              label: 'Frequently Asked Questions',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (var i = 0; i < helpFaqs.length; i++) ...[
                                    if (i > 0) const SizedBox(height: 12),
                                    FaqTile(entry: helpFaqs[i]),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            const FormSection(
                              label: 'Contact Support',
                              child: _ContactSupportCard(),
                            ),
                          ],
                        ),
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

/// A clearly labeled PLACEHOLDER for the future support contact details.
/// It has no email address, phone number, or link on purpose.
class _ContactSupportCard extends StatelessWidget {
  const _ContactSupportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardTint,
        borderRadius: BorderRadius.circular(AppLayout.fieldRadius),
        border: Border.all(color: AppColors.textPrimary),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.support_agent, size: 36, color: AppColors.primaryDark),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Placeholder',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Support contact details are not available yet. This '
                  'section is a placeholder and will be filled in when '
                  'GastoGuard has an official support channel.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
