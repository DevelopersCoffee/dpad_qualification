import 'package:dpad_qualification/dpad_qualification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'DeviceQualificationReportBuilder builds complete report when all phases pass',
    () {
      const builder = DeviceQualificationReportBuilder();

      final report = builder.build(
        reportId: 'rpt_001',
        campaignId: 'cmp_v1',
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

      expect(report.passedCount, equals(5));
      expect(report.failedCount, equals(0));
      expect(report.completeForIssueEvidence, isTrue);
      expect(report.toMarkdown(), contains('# Device Qualification Report'));
    },
  );

  test(
    'DeviceQualificationReportBuilder records findings for missing phase evidence',
    () {
      const builder = DeviceQualificationReportBuilder();

      final report = builder.build(
        reportId: 'rpt_002',
        campaignId: 'cmp_v1',
        deviceName: 'Google TV',
        appProfile: 'production',
        phaseStatuses: {'phase1_splash': DeviceQualificationPhaseStatus.passed},
      );

      expect(report.completeForIssueEvidence, isFalse);
      expect(report.findings, isNotEmpty);
      expect(report.findings.first.code, equals('missing_phase_evidence'));
    },
  );

  test('DeviceQualificationPhaseStatus.parse accepts aliases', () {
    expect(
      DeviceQualificationPhaseStatus.parse('passed'),
      DeviceQualificationPhaseStatus.passed,
    );
    expect(
      DeviceQualificationPhaseStatus.parse(' pass '),
      DeviceQualificationPhaseStatus.passed,
    );
    expect(
      DeviceQualificationPhaseStatus.parse('FAIL'),
      DeviceQualificationPhaseStatus.failed,
    );
    expect(
      DeviceQualificationPhaseStatus.parse('waive'),
      DeviceQualificationPhaseStatus.waived,
    );
    expect(
      () => DeviceQualificationPhaseStatus.parse('unknown'),
      throwsArgumentError,
    );
  });

  test('toPublicMap includes blocking findings and summary', () {
    const builder = DeviceQualificationReportBuilder();
    final report = builder.build(
      reportId: 'rpt_map',
      campaignId: 'cmp_map',
      deviceName: 'Fire TV',
      appProfile: 'qa',
      phaseStatuses: {'phase1_splash': DeviceQualificationPhaseStatus.failed},
      defectCounts: {'phase1_splash': 2},
    );

    expect(report.completeForIssueEvidence, isFalse);
    expect(
      report.findings.any((f) => f.blocking && f.code == 'failed_phase'),
      isTrue,
    );

    final map = report.toPublicMap();
    expect(map['reportId'], 'rpt_map');
    expect(map['summary'], isA<Map<String, Object?>>());
    final summary = map['summary']! as Map<String, Object?>;
    expect(summary['completeForIssueEvidence'], isFalse);
    expect(summary['failed'], 1);
    final phases = map['phases']! as List<Object?>;
    expect(phases.first, isA<Map<String, Object?>>());
  });
}
