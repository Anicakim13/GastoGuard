import 'package:flutter/material.dart';
import 'package:gastoguard/screens/dashboard_screen.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/widgets/gradient_button.dart';

/// The first screen of GastoGuard (Splash / Welcome screen).
///
/// Layout, top to bottom: logo, app name, tagline, illustration,
/// "GET STARTED" button, and a short caption.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sizes are based on the screen so the layout adapts to different phones.
    final screenSize = MediaQuery.sizeOf(context);
    final logoHeight = screenSize.height * 0.19;
    final sideMargin = screenSize.width * 0.10;

    return Scaffold(
      // The mint background color comes from AppTheme (scaffoldBackgroundColor).
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: screenSize.height * 0.04),

            // 1. Logo (shield + wallet)
            Image.asset('assets/images/logo.png', height: logoHeight),
            const SizedBox(height: 16),

            // 2. App name and tagline
            const Text(
              'GastoGuard',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 44,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Track. Plan. Save. Grow.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                letterSpacing: 1,
              ),
            ),

            // 3. Illustration: takes the leftover space, scaled to fit the width.
            //    The image already contains the mint background, so its edges
            //    blend into the screen.
            Expanded(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Image.asset(
      'assets/images/splash_illustration.png',
      width: double.infinity,
      fit: BoxFit.contain,
      alignment: Alignment.topCenter,
    ),
  ),
),

            // 4. Button and caption
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sideMargin),
              child: Column(
                children: [
                  GradientButton(
                    label: 'GET STARTED',
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      // pushReplacement swaps the Splash Screen for the
                      // Dashboard, so pressing Back on the Dashboard never
                      // returns to the Splash Screen.
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'A simple expense tracker for students',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenSize.height * 0.08),
          ],
        ),
      ),
    );
  }
}
