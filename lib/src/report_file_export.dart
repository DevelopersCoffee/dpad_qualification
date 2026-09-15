import 'dart:convert';
import 'dart:io';

import 'device_qualification_report.dart';

/// Writes [report] as JSON and Markdown files under [directoryPath].
Future<QualificationReportFiles> writeQualificationReportFiles({
  required DeviceQualificationReport report,
  required String directoryPath,
  String baseName = 'qualification-report',
}) async {
  final directory = Directory(directoryPath);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final jsonPath = '${directory.path}/$baseName.json';
  final markdownPath = '${directory.path}/$baseName.md';

  final jsonFile = File(jsonPath);
  final markdownFile = File(markdownPath);

  await jsonFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(report.toPublicMap()),
  );
  await markdownFile.writeAsString(report.toMarkdown());

  return QualificationReportFiles(
    jsonPath: jsonPath,
    markdownPath: markdownPath,
  );
}

class QualificationReportFiles {
  const QualificationReportFiles({
    required this.jsonPath,
    required this.markdownPath,
  });

  final String jsonPath;
  final String markdownPath;
}
