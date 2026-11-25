import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/main.dart';
import 'package:gastoguard/screens/dashboard_screen.dart';
import 'package:gastoguard/screens/help_support_screen.dart';
import 'package:gastoguard/services/help_faqs.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/services/transaction_store.dart';
import 'package:gastoguard/theme/app_theme.dart';

void main() {
  void useScreen(WidgetTester tester, Size logicalSize) {
    tester.view.physicalSize = logicalSize * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // The Help & Support screen on its own.
  Future<void> pumpHelp(
    WidgetTester tester, {
    Size size = const Size(393, 852),
  }) async {
    useScreen(tester, size);
    // Start from an empty screen, so nothing is carried over from an earlier
    // pump in the same test (Flutter reuses the old app's state otherwise).
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const HelpSupportScreen()),
    );
  }

  // Taps a question and waits for it to open or close.
  Future<void> tapQuestion(WidgetTester tester, FaqEntry faq) async {
    await tester.ensureVisible(find.text(faq.question));
    await tester.tap(find.text(faq.question));
    await tester.pumpAndSettle();
  }

  // Every piece of text currently on the screen.
  List<String> allTexts(WidgetTester tester) => [
        for (final text in tester.widgetList<Text>(find.byType(Text)))
          text.data ?? text.textSpan?.toPlainText() ?? '',
      ];

  // The Dashboard as the first screen, with the sample transactions.
  Future<(Element, TransactionStore)> pumpDashboard(WidgetTester tester) async {
    useScreen(tester, const Size(393, 852));
    final store = TransactionStore.withDemoData(DateTime(2026, 11, 15));
    await tester.pumpWidget(
      TransactionScope(
        store: store,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const DashboardScreen(),
        ),
      ),
    );
    return (tester.element(find.byType(DashboardScreen)), store);
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
  }

  testWidgets('Help & Support shows the title, the questions, and Contact Support',
      (WidgetTester tester) async {
    await pumpHelp(tester);

    expect(find.text('Help & Support'), findsOneWidget); // the title
    expect(find.text('Frequently Asked Questions'), findsOneWidget);
    expect(find.text('Contact Support'), findsOneWidget);

    // All five questions are there, and their answers are hidden at first.
    expect(helpFaqs.length, 5);
    for (final faq in helpFaqs) {
      expect(find.text(faq.question), findsOneWidget);
      expect(find.text(faq.answer), findsNothing);
    }
  });

  testWidgets('Tapping a question shows its answer, and tapping again hides it',
      (WidgetTester tester) async {
    await pumpHelp(tester);
    final faq = helpFaqs.first;

    await tapQuestion(tester, faq);
    expect(find.text(faq.answer), findsOneWidget);

    await tapQuestion(tester, faq);
    expect(find.text(faq.answer), findsNothing);
  });

  testWidgets('Each question opens its own answer',
      (WidgetTester tester) async {
    await pumpHelp(tester);

    for (final faq in helpFaqs) {
      await tapQuestion(tester, faq);
      expect(find.text(faq.answer), findsOneWidget, reason: faq.question);
      // Only this answer is open.
      for (final other in helpFaqs.where((f) => f != faq)) {
        expect(find.text(other.answer), findsNothing);
      }
      await tapQuestion(tester, faq); // close it again
    }
  });

  testWidgets('Several questions can be open at the same time',
      (WidgetTester tester) async {
    await pumpHelp(tester);

    await tapQuestion(tester, helpFaqs[0]);
    await tapQuestion(tester, helpFaqs[3]);

    expect(find.text(helpFaqs[0].answer), findsOneWidget);
    expect(find.text(helpFaqs[3].answer), findsOneWidget);
    expect(find.text(helpFaqs[1].answer), findsNothing);
  });

  testWidgets('Contact Support is a clearly labeled placeholder',
      (WidgetTester tester) async {
    await pumpHelp(tester);

    expect(find.text('Placeholder'), findsOneWidget);
    expect(
      find.text(
        'Support contact details are not available yet. This section is a '
        'placeholder and will be filled in when GastoGuard has an official '
        'support channel.',
      ),
      findsOneWidget,
    );

    // Nothing to tap: no button or link was invented.
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('No email address, phone number, or web address is shown',
      (WidgetTester tester) async {
    await pumpHelp(tester);
    for (final faq in helpFaqs) {
      await tapQuestion(tester, faq); // open every answer too
    }

    for (final text in allTexts(tester)) {
      expect(text.contains('@'), isFalse, reason: text);
      expect(text.toLowerCase().contains('http'), isFalse, reason: text);
      expect(text.toLowerCase().contains('www.'), isFalse, reason: text);
    }
  });

  testWidgets('Every answer fits on a small phone and on a wide web window',
      (WidgetTester tester) async {
    for (final size in const [Size(320, 568), Size(1280, 800)]) {
      await pumpHelp(tester, size: size);

      for (final faq in helpFaqs) {
        await tapQuestion(tester, faq);
      }

      // flutter_test fails the test by itself if a layout overflow happens.
      expect(tester.takeException(), isNull);
      for (final faq in helpFaqs) {
        expect(find.text(faq.answer), findsOneWidget);
      }
      expect(find.text('Contact Support'), findsOneWidget);
    }
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
                  MaterialPageRoute<void>(
                    builder: (_) => const HelpSupportScreen(),
                  ),
                ),
                child: const Text('Open help'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open help'));
    await tester.pumpAndSettle();
    expect(find.byType(HelpSupportScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(HelpSupportScreen), findsNothing);
    expect(find.text('Open help'), findsOneWidget);
  });

  testWidgets('The back arrow does nothing when Help is the only screen',
      (WidgetTester tester) async {
    await pumpHelp(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(HelpSupportScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Help & Support in the drawer opens the screen, and back returns '
      'to the same Dashboard', (WidgetTester tester) async {
    final (dashboard, store) = await pumpDashboard(tester);
    await openMenu(tester);

    await tester.tap(find.text('Help & Support'));
    await tester.pumpAndSettle();

    expect(find.byType(HelpSupportScreen), findsOneWidget);
    expect(find.text('Frequently Asked Questions'), findsOneWidget);
    expect(find.text('Help & Support is coming soon'), findsNothing);
    expect(find.text('Renz'), findsNothing); // the drawer closed

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(HelpSupportScreen), findsNothing);
    expect(find.byType(DashboardScreen, skipOffstage: false), findsOneWidget);
    expect(tester.element(find.byType(DashboardScreen)), same(dashboard));
    expect(Navigator.of(dashboard).canPop(), isFalse);
    // Help does not touch any transactions.
    expect(store.transactions.length, 14);
  });

  testWidgets('Help & Support works in the real app',
      (WidgetTester tester) async {
    useScreen(tester, const Size(393, 852));
    await tester.pumpWidget(const GastoGuardApp());

    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();
    final dashboard = tester.element(find.byType(DashboardScreen));

    await openMenu(tester);
    await tester.tap(find.text('Help & Support'));
    await tester.pumpAndSettle();
    expect(find.byType(HelpSupportScreen), findsOneWidget);

    // Open the first question, then go back.
    await tapQuestion(tester, helpFaqs.first);
    expect(find.text(helpFaqs.first.answer), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(HelpSupportScreen), findsNothing);
    expect(tester.element(find.byType(DashboardScreen)), same(dashboard));
    expect(Navigator.of(dashboard).canPop(), isFalse);
  });
}
