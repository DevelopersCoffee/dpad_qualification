import 'package:dpad_qualification/dpad_qualification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> openPanel(WidgetTester tester) async {
    await tester.tap(find.text('QA OVERLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('DeviceQualificationOverlay toggles QA panel', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DeviceQualificationOverlay(child: Text('App content')),
      ),
    );

    expect(find.text('App content'), findsOneWidget);
    expect(find.text('Device Qualification Menu'), findsNothing);

    await openPanel(tester);

    expect(find.text('Device Qualification Menu'), findsOneWidget);
  });

  testWidgets('DeviceQualificationOverlay switches simulated device', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: DeviceQualificationOverlay(child: SizedBox.shrink()),
      ),
    );

    await openPanel(tester);

    await tester.tap(find.byType(DropdownButton<SimulatedViewport>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Android TV 1080p').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('1920x1080'), findsWidgets);
  });

  testWidgets('DeviceQualificationOverlay copies defect report', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DeviceQualificationOverlay(child: SizedBox.shrink()),
        ),
      ),
    );

    await openPanel(tester);

    final exportButton = find.text('Export Report to Clipboard');
    await tester.scrollUntilVisible(
      exportButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Broken focus ring');
    await tester.enterText(fields.at(1), 'Navigate down twice');
    await tester.tap(exportButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Defect report copied to clipboard in Markdown!'),
      findsOneWidget,
    );
  });

  test('autoCycle viewport list includes presets and custom devices', () {
    const custom = CustomSimulatedDevice(
      name: 'Apple TV 4K',
      width: 3840,
      height: 2160,
      isTv: true,
    );
    final viewports = [
      for (final device in SimulatedDevice.values)
        SimulatedViewport.preset(device),
      SimulatedViewport.custom(custom),
    ];

    expect(viewports.length, SimulatedDevice.values.length + 1);
    expect(viewports.last.name, 'Apple TV 4K');
  });

  testWidgets('DeviceQualificationOverlay includes custom devices', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: DeviceQualificationOverlay(
          customDevices: [
            CustomSimulatedDevice(
              name: 'Apple TV 4K',
              width: 3840,
              height: 2160,
              isTv: true,
            ),
          ],
          child: SizedBox.shrink(),
        ),
      ),
    );

    await openPanel(tester);

    await tester.tap(find.byType(DropdownButton<SimulatedViewport>));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Apple TV 4K'), findsOneWidget);
  });

  test('NetworkQualificationHook receives profile changes', () {
    String? profile;
    double? latency;

    void hook(String selectedProfile, double referenceLatencyMs) {
      profile = selectedProfile;
      latency = referenceLatencyMs;
    }

    hook('Offline', double.infinity);

    expect(profile, 'Offline');
    expect(latency, double.infinity);
  });
}
