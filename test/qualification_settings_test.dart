import 'package:dpad_qualification/dpad_qualification.dart';
import 'package:dpad_qualification/src/qualification_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('QualificationSettingsStore round-trips defect draft', () async {
    final store = QualificationSettingsStore();
    final viewport = SimulatedViewport.preset(SimulatedDevice.androidTv1080p);

    await store.save(
      viewport: viewport,
      showBezel: true,
      networkProfile: 'Excellent WiFi',
      defectDraft: const DefectDraft(
        title: 'Focus bug',
        description: 'Steps',
        severity: 'P1',
        category: 'Navigation / Focus',
      ),
    );

    final loaded = await store.load(customDevices: const []);
    expect(loaded, isNotNull);
    expect(loaded!.defectDraft?.title, 'Focus bug');
    expect(loaded.defectDraft?.description, 'Steps');
    expect(loaded.defectDraft?.severity, 'P1');
  });
}
