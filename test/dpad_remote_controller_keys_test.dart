import 'package:dpad_qualification/dpad_qualification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpRemote(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DpadRemoteController())),
    );
  }

  Future<List<KeyDownEvent>> tapAndCollectKeyDowns(
    WidgetTester tester,
    Finder tapTarget,
  ) async {
    final downs = <KeyDownEvent>[];
    bool handler(KeyEvent event) {
      if (event is KeyDownEvent) {
        downs.add(event);
      }
      return false;
    }

    HardwareKeyboard.instance.addHandler(handler);
    addTearDown(() => HardwareKeyboard.instance.removeHandler(handler));

    await tester.tap(tapTarget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    return downs;
  }

  testWidgets('dispatches arrow and OK keys', (tester) async {
    await pumpRemote(tester);

    final up = await tapAndCollectKeyDowns(
      tester,
      find.byIcon(Icons.arrow_drop_up),
    );
    expect(up.any((e) => e.logicalKey == LogicalKeyboardKey.arrowUp), isTrue);

    final down = await tapAndCollectKeyDowns(
      tester,
      find.byIcon(Icons.arrow_drop_down),
    );
    expect(
      down.any((e) => e.logicalKey == LogicalKeyboardKey.arrowDown),
      isTrue,
    );

    final left = await tapAndCollectKeyDowns(
      tester,
      find.byIcon(Icons.arrow_left),
    );
    expect(
      left.any((e) => e.logicalKey == LogicalKeyboardKey.arrowLeft),
      isTrue,
    );

    final right = await tapAndCollectKeyDowns(
      tester,
      find.byIcon(Icons.arrow_right),
    );
    expect(
      right.any((e) => e.logicalKey == LogicalKeyboardKey.arrowRight),
      isTrue,
    );

    final ok = await tapAndCollectKeyDowns(tester, find.text('OK'));
    expect(ok.any((e) => e.logicalKey == LogicalKeyboardKey.enter), isTrue);

    final menu = await tapAndCollectKeyDowns(tester, find.text('MENU'));
    expect(menu.any((e) => e.logicalKey == LogicalKeyboardKey.f1), isTrue);

    final play = await tapAndCollectKeyDowns(
      tester,
      find.byIcon(Icons.play_arrow),
    );
    expect(play.any((e) => e.logicalKey == LogicalKeyboardKey.space), isTrue);

    final home = await tapAndCollectKeyDowns(tester, find.byIcon(Icons.home));
    expect(home.any((e) => e.logicalKey == LogicalKeyboardKey.home), isTrue);

    final back = await tapAndCollectKeyDowns(
      tester,
      find.byIcon(Icons.keyboard_return),
    );
    expect(back.any((e) => e.logicalKey == LogicalKeyboardKey.escape), isTrue);
  });
}
