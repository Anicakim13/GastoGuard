import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/main.dart';

void main() {
  testWidgets('Splash screen shows the app name, button, and caption',
      (WidgetTester tester) async {
    // Pretend to be a typical phone (393 x 852 logical pixels).
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GastoGuardApp());

    expect(find.text('GastoGuard'), findsOneWidget);
    expect(find.text('Track. Plan. Save. Grow.'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
    expect(find.text('A simple expense tracker for students'), findsOneWidget);
  });
}
