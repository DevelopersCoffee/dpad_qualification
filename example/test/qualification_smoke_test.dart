import 'package:dpad_qualification_example/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';

void main() {
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
