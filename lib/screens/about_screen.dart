import 'package:flutter/material.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';
import 'package:gastoguard/widgets/screen_header.dart';

/// The "About GastoGuard" screen: the logo, the app name, a short
/// description, and a closing line.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _tagline = 'Track. Plan. Save. Grow.';
  static const String _descriptionRest =
      ' is a simple, offline-friendly expense tracker designed for students.';
  static const String _descriptionMore =
      'It helps you record, organize, and monitor your income and expenses so '
      'you can build better spending habits and achieve your financial goals.';
  static const String _closingLine = 'For a Smarter. Brighter Tomorrow';

  @override
  Widget build(BuildContext context) {
    // The logo is a little smaller on short screens.
    final logoHeight =
        (MediaQuery.sizeOf(context).height * 0.15).clamp(90.0, 140.0).toDouble();

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
                    const ScreenHeader(title: 'About GastoGuard'),

                    // Everything in the middle scrolls on small screens.
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(sideMargin, 16, sideMargin, 16),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: logoHeight,
                            ),
                            const SizedBox(height: 28),

                            // The app name is very big; it shrinks if the
                            // screen is too narrow for it.
                            const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'GastoGuard',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 56,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              _tagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 19,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 34),

                            const _DescriptionCard(),
                          ],
                        ),
                      ),
                    ),

                    // The closing line stays near the bottom of the screen.
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 8, 24, 36),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _closingLine,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
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

/// The dark green rounded card with the description in white.
class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard();

  static const TextStyle _textStyle = TextStyle(
    color: AppColors.textOnGreen,
    fontSize: 16,
    height: 1.4,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textPrimary),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // "GastoGuard" is bold, the rest of the sentence is normal.
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'GastoGuard',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: AboutScreen._descriptionRest),
              ],
            ),
            style: _textStyle,
          ),
          SizedBox(height: 22),
          Text(
            AboutScreen._descriptionMore,
            textAlign: TextAlign.justify,
            style: _textStyle,
          ),
        ],
      ),
    );
  }
}
