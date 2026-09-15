/// Builds a GitHub new-issue URL with prefilled title and body.
Uri buildGitHubIssueUrl({
  required String issueTrackerBase,
  required String title,
  required String body,
}) {
  final base = Uri.parse(issueTrackerBase);
  final normalizedPath = base.path.replaceAll(RegExp(r'/+$'), '');
  final issuesNewPath = normalizedPath.endsWith('/issues/new')
      ? normalizedPath
      : normalizedPath.endsWith('/issues')
      ? '$normalizedPath/new'
      : '$normalizedPath/issues/new';

  return base.replace(
    path: issuesNewPath,
    queryParameters: {'title': title, 'body': body},
  );
}
