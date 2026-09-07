import 'package:dpad_qualification/dpad_qualification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DpadRemoteController renders remote control buttons and triggers callbacks', (
    WidgetTester tester,
  ) async {
    bool backPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DpadRemoteController(
            onBackPress: () {
              backPressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('D-PAD REMOTE'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('MENU'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.power_settings_new));
    await tester.pump();

    expect(backPressed, isTrue);
  });
}
