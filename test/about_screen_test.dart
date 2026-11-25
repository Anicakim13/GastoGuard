import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/screens/about_screen.dart';
import 'package:gastoguard/theme/app_theme.dart';

void main() {
  void useScreen(WidgetTester tester, Size logicalSize) {
    tester.view.physicalSize = logicalSize * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpAbout(
    WidgetTester tester, {
    Size size = const Size(393, 852),
  }) async {
    useScreen(tester, size);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AboutScreen()),
    );
  }

  testWidgets('About shows every part of the design',
      (WidgetTester tester) async {
    await pumpAbout(tester);

    expect(find.text('About GastoGuard'), findsOneWidget); // the title
    expect(find.text('GastoGuard'), findsOneWidget); // the big app name
    expect(find.text('Track. Plan. Save. Grow.'), findsOneWidget);
    expect(
      find.text(
        'GastoGuard is a simple, offline-friendly expense tracker designed '
        'for students.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'It helps you record, organize, and monitor your income and expenses '
        'so you can build better spending habits and achieve your financial '
        'goals.',
      ),
      findsOneWidget,
    );
    expect(find.text('For a Smarter. Brighter Tomorrow'), findsOneWidget);

    // The logo is the existing logo from the Splash Screen.
    final logo = tester.widget<Image>(find.byType(Image));
    expect(logo.image, const AssetImage('assets/images/logo.png'));
  });

  testWidgets('The back arrow returns to the screen before',
      (WidgetTester tester) async {
    useScreen(tester, const Size(393, 852));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
                ),
                child: const Text('Open about'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open about'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutScreen), findsNothing);
    expect(find.text('Open about'), findsOneWidget);
  });

  testWidgets('The back arrow does nothing when About is the only screen',
      (WidgetTester tester) async {
    await pumpAbout(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('About does not overflow on a small phone',
      (WidgetTester tester) async {
    await pumpAbout(tester, size: const Size(320, 568));
    // flutter_test fails the test by itself if a layout overflow happens.
    expect(find.text('GastoGuard'), findsOneWidget);
    expect(find.text('For a Smarter. Brighter Tomorrow'), findsOneWidget);
  });

  testWidgets('About scrolls instead of overflowing on a very short screen',
      (WidgetTester tester) async {
    await pumpAbout(tester, size: const Size(320, 360));
    expect(tester.takeException(), isNull);
    expect(find.text('About GastoGuard'), findsOneWidget);
  });

  testWidgets('About does not overflow on a wide web window',
      (WidgetTester tester) async {
    await pumpAbout(tester, size: const Size(1280, 800));
    expect(find.text('GastoGuard'), findsOneWidget);
    expect(find.text('For a Smarter. Brighter Tomorrow'), findsOneWidget);
  });
}
