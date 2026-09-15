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

  testWidgets(
    'ResolutionSimulator renders bezel and scaled viewport for TV device',
    (WidgetTester tester) async {
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
    },
  );

  testWidgets('ResolutionSimulator.viewport renders custom device bezel', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResolutionSimulator.viewport(
          viewport: SimulatedViewport.custom(
            const CustomSimulatedDevice(
              name: 'Apple TV 4K',
              width: 3840,
              height: 2160,
              isTv: true,
            ),
          ),
          child: const Text('custom child'),
        ),
      ),
    );

    expect(find.text('custom child'), findsOneWidget);
    expect(find.textContaining('Apple TV 4K'), findsOneWidget);
  });
}
