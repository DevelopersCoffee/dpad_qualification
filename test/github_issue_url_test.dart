import 'package:dpad_qualification/dpad_qualification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildGitHubIssueUrl prefills title and body', () {
    final url = buildGitHubIssueUrl(
      issueTrackerBase:
          'https://github.com/DevelopersCoffee/dpad_qualification/issues',
      title: 'Focus ring missing',
      body: 'Steps to reproduce...',
    );

    expect(url.host, 'github.com');
    expect(url.queryParameters['title'], 'Focus ring missing');
    expect(url.queryParameters['body'], 'Steps to reproduce...');
    expect(url.path, contains('issues/new'));
  });
}
