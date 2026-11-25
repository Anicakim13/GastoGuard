import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/theme/app_theme.dart';
import 'package:gastoguard/widgets/app_drawer.dart';

void main() {
  void useScreen(WidgetTester tester, Size logicalSize) {
    tester.view.physicalSize = logicalSize * 3;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // A screen with a button that opens the drawer. Every tap on a menu item is
  // written into [calls], so the tests can see which item was chosen.
  Future<void> pumpDrawer(
    WidgetTester tester,
    List<String> calls, {
    Size size = const Size(393, 852),
    String userName = 'Renz',
  }) async {
    useScreen(tester, size);
    // Start from an empty screen. Pumping a new MaterialApp straight over an
    // old one would REUSE the old app's state, so a drawer left open by an
    // earlier check in the same test would still be open (and would cover the
    // "Open menu" button).
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          drawer: AppDrawer(
            userName: userName,
            onBudgetSettings: () => calls.add('budget'),
            onAbout: () => calls.add('about'),
            onHelpAndSupport: () => calls.add('help'),
            onDarkMode: () => calls.add('dark'),
            onDeleteData: () => calls.add('delete'),
          ),
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open menu'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.text('Open menu'));
    await tester.pumpAndSettle();
  }

  testWidgets('The drawer shows the profile and all five menu items',
      (WidgetTester tester) async {
    await pumpDrawer(tester, []);
    await openMenu(tester);

    expect(find.text('Renz'), findsOneWidget);
    expect(find.text('Track. Smart. Spent Better'), findsOneWidget);
    expect(find.text('Budget Settings'), findsOneWidget);
    expect(find.text('About GastoGuard'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Delete Data'), findsOneWidget);

    // The profile picture and the five outlined icons.
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(find.byIcon(Icons.contrast), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('Each menu item closes the drawer and calls its own action',
      (WidgetTester tester) async {
    final calls = <String>[];
    await pumpDrawer(tester, calls);

    final items = {
      'Budget Settings': 'budget',
      'About GastoGuard': 'about',
      'Help & Support': 'help',
      'Dark Mode': 'dark',
      'Delete Data': 'delete',
    };

    for (final entry in items.entries) {
      await openMenu(tester);
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();

      expect(calls.last, entry.value);
      expect(find.text('Renz'), findsNothing); // the drawer is closed again
    }
    expect(calls, ['budget', 'about', 'help', 'dark', 'delete']);
  });

  testWidgets('The drawer is about two thirds of the screen width, within limits',
      (WidgetTester tester) async {
    // A normal phone: 67% of 393 is about 263.
    await pumpDrawer(tester, []);
    await openMenu(tester);
    expect(tester.getSize(find.byType(Drawer)).width, closeTo(263.3, 1));

    // A narrow phone: never narrower than 250.
    await pumpDrawer(tester, [], size: const Size(320, 568));
    await openMenu(tester);
    expect(tester.getSize(find.byType(Drawer)).width, 250);

    // A wide browser window: never wider than 300.
    await pumpDrawer(tester, [], size: const Size(1280, 800));
    await openMenu(tester);
    expect(tester.getSize(find.byType(Drawer)).width, 300);
  });

  testWidgets('A very long name does not overflow',
      (WidgetTester tester) async {
    await pumpDrawer(
      tester,
      [],
      userName: 'A very long name that is much too wide for the drawer',
    );
    await openMenu(tester);

    // flutter_test fails the test by itself if a layout overflow happens.
    expect(
      find.text('A very long name that is much too wide for the drawer'),
      findsOneWidget,
    );
  });

  testWidgets('The drawer scrolls on a very short screen',
      (WidgetTester tester) async {
    await pumpDrawer(tester, [], size: const Size(320, 300));
    await openMenu(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Delete Data'), findsOneWidget);
  });

  testWidgets('Tapping outside the drawer closes it',
      (WidgetTester tester) async {
    await pumpDrawer(tester, []);
    await openMenu(tester);
    expect(find.text('Renz'), findsOneWidget);

    await tester.tapAt(const Offset(380, 600)); // to the right of the drawer
    await tester.pumpAndSettle();

    expect(find.text('Renz'), findsNothing);
  });
}
