import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:dpad_qualification_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('example app loads qualification overlay', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('QA OVERLAY'), findsOneWidget);
    expect(find.text('Flutter Smart TV Navigation Demo'), findsOneWidget);

    await tester.tap(find.text('QA OVERLAY'));
    await tester.pumpAndSettle();

    expect(find.text('Device Qualification Menu'), findsOneWidget);
  });
}
