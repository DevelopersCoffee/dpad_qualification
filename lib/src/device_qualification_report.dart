const List<DeviceQualificationPhaseDefinition> kDefaultQualificationPhases = [
  DeviceQualificationPhaseDefinition(
    id: 'phase1_splash',
    title: 'Phase 1: Splash Screen & Boot',
  ),
  DeviceQualificationPhaseDefinition(
    id: 'phase1_home',
    title: 'Phase 1: Home & Primary Screen',
  ),
  DeviceQualificationPhaseDefinition(
    id: 'phase2_responsive_layouts',
    title: 'Phase 2: Responsive Layout Breakpoints',
  ),
  DeviceQualificationPhaseDefinition(
    id: 'phase3_dpad_focus',
    title: 'Phase 3: D-Pad Navigation and Focus States',
  ),
  DeviceQualificationPhaseDefinition(
    id: 'phase4_performance_stress',
    title: 'Phase 4: Telemetry & Frame Rate Stress Checks',
  ),
];

enum DeviceQualificationPhaseStatus {
  passed('passed'),
  failed('failed'),
  waived('waived'),
  missing('missing');

  const DeviceQualificationPhaseStatus(this.stableId);

  final String stableId;

  bool get complete => this == passed || this == waived;

  static DeviceQualificationPhaseStatus parse(String value) {
    final normalized = value.trim().toLowerCase();
    for (final status in values) {
      if (status.stableId == normalized) {
        return status;
      }
    }
    if (normalized == 'pass') return passed;
    if (normalized == 'fail') return failed;
    if (normalized == 'waive') return waived;
    throw ArgumentError.value(value, 'value', 'Unsupported phase status.');
  }
}

class DeviceQualificationPhaseDefinition {
  const DeviceQualificationPhaseDefinition({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}

class DeviceQualificationPhaseResult {
  const DeviceQualificationPhaseResult({
    required this.id,
    required this.title,
    required this.status,
    this.defectCount = 0,
    this.note = '',
  });

  final String id;
  final String title;
  final DeviceQualificationPhaseStatus status;
  final int defectCount;
  final String note;

  bool get complete {
    if (status == DeviceQualificationPhaseStatus.waived) {
      return true;
    }
    return status == DeviceQualificationPhaseStatus.passed && defectCount == 0;
  }

  Map<String, Object?> toPublicMap() {
    return {
      'id': id,
      'title': title,
      'status': status.stableId,
      'defectCount': defectCount,
      'note': note,
      'complete': complete,
    };
  }
}

class DeviceQualificationFinding {
  const DeviceQualificationFinding({
    required this.code,
    required this.message,
    this.blocking = true,
  });

  final String code;
  final String message;
  final bool blocking;

  Map<String, Object?> toPublicMap() {
    return {'code': code, 'message': message, 'blocking': blocking};
  }
}

class DeviceQualificationReport {
  DeviceQualificationReport({
    required this.reportId,
    required this.campaignId,
    required this.deviceName,
    required this.appProfile,
    required Iterable<DeviceQualificationPhaseResult> phases,
    required Iterable<DeviceQualificationFinding> findings,
    this.schemaVersion = '1.0.0',
  }) : phases = List.unmodifiable(phases),
       findings = List.unmodifiable(findings);

  final String schemaVersion;
  final String reportId;
  final String campaignId;
  final String deviceName;
  final String appProfile;
  final List<DeviceQualificationPhaseResult> phases;
  final List<DeviceQualificationFinding> findings;

  int get passedCount => phases
      .where((phase) => phase.status == DeviceQualificationPhaseStatus.passed)
      .length;
  int get failedCount => phases
      .where((phase) => phase.status == DeviceQualificationPhaseStatus.failed)
      .length;
  int get waivedCount => phases
      .where((phase) => phase.status == DeviceQualificationPhaseStatus.waived)
      .length;
  int get missingCount => phases
      .where((phase) => phase.status == DeviceQualificationPhaseStatus.missing)
      .length;
  int get defectCount =>
      phases.fold<int>(0, (total, phase) => total + phase.defectCount);

  bool get completeForIssueEvidence =>
      phases.isNotEmpty &&
      phases.every((phase) => phase.complete) &&
      !findings.any((finding) => finding.blocking);

  Map<String, Object?> toPublicMap() {
    return {
      'schemaVersion': schemaVersion,
      'reportId': reportId,
      'campaignId': campaignId,
      'deviceName': deviceName,
      'appProfile': appProfile,
      'summary': {
        'completeForIssueEvidence': completeForIssueEvidence,
        'passed': passedCount,
        'failed': failedCount,
        'waived': waivedCount,
        'missing': missingCount,
        'defects': defectCount,
      },
      'phases': phases.map((phase) => phase.toPublicMap()).toList(),
      'findings': findings.map((finding) => finding.toPublicMap()).toList(),
    };
  }

  String toMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# Device Qualification Report')
      ..writeln()
      ..writeln('| Area | Value |')
      ..writeln('| --- | --- |')
      ..writeln('| Report | `$reportId` |')
      ..writeln('| Campaign | `$campaignId` |')
      ..writeln('| Device | $deviceName |')
      ..writeln('| App profile | `$appProfile` |')
      ..writeln('| Complete for evidence | `$completeForIssueEvidence` |')
      ..writeln('| Passed | `$passedCount` |')
      ..writeln('| Failed | `$failedCount` |')
      ..writeln('| Waived | `$waivedCount` |')
      ..writeln('| Missing | `$missingCount` |')
      ..writeln('| Defects | `$defectCount` |')
      ..writeln()
      ..writeln('## Phases')
      ..writeln()
      ..writeln('| Phase | Status | Defects | Note |')
      ..writeln('| --- | --- | --- | --- |');

    for (final phase in phases) {
      buffer.writeln(
        '| ${phase.title} | `${phase.status.stableId}` | '
        '`${phase.defectCount}` | ${phase.note} |',
      );
    }

    if (findings.isEmpty) {
      buffer
        ..writeln()
        ..writeln('No findings.');
      return buffer.toString();
    }

    buffer
      ..writeln()
      ..writeln('## Findings')
      ..writeln()
      ..writeln('| Code | Blocking | Message |')
      ..writeln('| --- | --- | --- |');
    for (final finding in findings) {
      buffer.writeln(
        '| `${finding.code}` | `${finding.blocking}` | ${finding.message} |',
      );
    }

    return buffer.toString();
  }
}

class DeviceQualificationReportBuilder {
  const DeviceQualificationReportBuilder({
    this.phaseDefinitions = kDefaultQualificationPhases,
  });

  final List<DeviceQualificationPhaseDefinition> phaseDefinitions;

  DeviceQualificationReport build({
    required String reportId,
    required String campaignId,
    required String deviceName,
    required String appProfile,
    required Map<String, DeviceQualificationPhaseStatus> phaseStatuses,
    Map<String, int> defectCounts = const {},
    Map<String, String> notes = const {},
  }) {
    final phases = <DeviceQualificationPhaseResult>[];
    final findings = <DeviceQualificationFinding>[];

    for (final definition in phaseDefinitions) {
      final status =
          phaseStatuses[definition.id] ??
          DeviceQualificationPhaseStatus.missing;
      final defectCount = defectCounts[definition.id] ?? 0;
      final note = notes[definition.id] ?? '';
      phases.add(
        DeviceQualificationPhaseResult(
          id: definition.id,
          title: definition.title,
          status: status,
          defectCount: defectCount,
          note: note,
        ),
      );

      if (status == DeviceQualificationPhaseStatus.missing) {
        findings.add(
          DeviceQualificationFinding(
            code: 'missing_phase_evidence',
            message: '${definition.title} has no recorded evidence.',
          ),
        );
      } else if (status == DeviceQualificationPhaseStatus.failed) {
        findings.add(
          DeviceQualificationFinding(
            code: 'failed_phase',
            message: '${definition.title} failed and needs defect triage.',
          ),
        );
      }
      if (status != DeviceQualificationPhaseStatus.waived && defectCount > 0) {
        findings.add(
          DeviceQualificationFinding(
            code: 'unwaived_defects',
            message:
                '${definition.title} has $defectCount defect(s) without a waiver.',
          ),
        );
      }
    }

    return DeviceQualificationReport(
      reportId: reportId,
      campaignId: campaignId,
      deviceName: deviceName,
      appProfile: appProfile,
      phases: phases,
      findings: findings,
    );
  }
}
