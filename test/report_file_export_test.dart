import 'dart:io';

import 'package:dpad_qualification/dpad_qualification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('writeQualificationReportFiles writes json and markdown', () async {
    final directory = Directory.systemTemp.createTempSync('dpad-report-test');
    addTearDown(() {
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });

    const builder = DeviceQualificationReportBuilder();
    final report = builder.build(
      reportId: 'rpt_file',
      campaignId: 'cmp_file',
      deviceName: 'Shield TV 4K',
      appProfile: 'production',
      phaseStatuses: {
        'phase1_splash': DeviceQualificationPhaseStatus.passed,
        'phase1_home': DeviceQualificationPhaseStatus.passed,
        'phase2_responsive_layouts': DeviceQualificationPhaseStatus.passed,
        'phase3_dpad_focus': DeviceQualificationPhaseStatus.passed,
        'phase4_performance_stress': DeviceQualificationPhaseStatus.passed,
      },
    );

    final files = await writeQualificationReportFiles(
      report: report,
      directoryPath: directory.path,
      baseName: 'release-signoff',
    );

    expect(File(files.jsonPath).existsSync(), isTrue);
    expect(File(files.markdownPath).existsSync(), isTrue);
    expect(
      File(files.markdownPath).readAsStringSync(),
      contains('# Device Qualification Report'),
    );
  });
}
