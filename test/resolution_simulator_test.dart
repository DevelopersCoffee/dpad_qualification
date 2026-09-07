import 'package:dpad_qualification/dpad_qualification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ResolutionSimulator renders child directly when native', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ResolutionSimulator(
          device: SimulatedDevice.native,
          child: Text('Native View'),
        ),
      ),
    );

    expect(find.text('Native View'), findsOneWidget);
    expect(find.textContaining('Android TV'), findsNothing);
  });

  testWidgets('ResolutionSimulator renders bezel and scaled viewport for TV device', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ResolutionSimulator(
          device: SimulatedDevice.androidTv1080p,
          child: Text('TV App Content'),
        ),
      ),
    );

    expect(find.text('TV App Content'), findsOneWidget);
    expect(find.textContaining('Android TV 1080p'), findsOneWidget);
  });
}
