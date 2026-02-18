import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpme/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Set realistic phone screen size (iPhone 14 Pro logical resolution)
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const HelpMeApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('HelpMe'), findsOneWidget);
    expect(find.textContaining('Ich brauche'), findsOneWidget);
    expect(find.textContaining('Ich biete'), findsOneWidget);
  });
}
