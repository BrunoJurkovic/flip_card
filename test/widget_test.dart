// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flip_card/flip_card.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final frontKey = Key('front');
    final backKey = Key('back');
    await tester.pumpWidget(new FlipCard(
      front: Container(
        key: frontKey,
        child: Text('front'),
      ),
      back: Container(
        key: backKey,
        child: Text('back'),
      ),
    ));

    expect(
      tester
      .widgetList<Text>(find.byType(Text)),
    equals(2));

    tester.tap(find.byType(Stack));

    sleep(const Duration(seconds:1));
    
  });
}
