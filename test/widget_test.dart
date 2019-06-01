// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flip_card/flip_card.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final frontKey = Key('front');
    final backKey = Key('back');
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: new FlipCard(
        front: Container(
          key: frontKey,
          child: Text('front'),
        ),
        back: Container(
          key: backKey,
          child: Text('back'),
        ),
      ),
    ));

    expect(find.byType(Text), findsNWidgets(2));
    await tester.tap(find.byType(Stack));
  });

  group('background interactions', () {
    testWidgets('are blocked by default', (WidgetTester tester) async {
      // check that background touches are blocked
      bool backgroundTouched = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: new FlipCard(
            front: Text('front'),
            back: RaisedButton(
              onPressed: () => backgroundTouched = true,
              child: Text('back'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RaisedButton));
      expect(backgroundTouched, false);
    });

    testWidgets('can be turned on', (WidgetTester tester) async {
      bool backgroundTouched = false;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: new FlipCard(
            front: Text('front'),
            back: RaisedButton(
              onPressed: () => backgroundTouched = true,
              child: Text('back'),
            ),
            blockInactiveInteractions: false,
          ),
        ),
      );

      await tester.tap(find.byType(RaisedButton));
      expect(backgroundTouched, true);
    });
  });

  group('cards flip', () {
    testWidgets('automatically', (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: new FlipCard(
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );
      final state = tester.state<FlipCardState>(find.byType(FlipCard));

      expect(state.isFront, isTrue);

      await tester.tap(find.byType(FlipCard));
      await tester.pumpAndSettle();

      expect(state.isFront, isFalse);
    });

    testWidgets('manually', (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: new FlipCard(
            flipOnTouch: false,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );
      final state = tester.state<FlipCardState>(find.byType(FlipCard));

      await tester.tap(find.byType(FlipCard));
      await tester.pumpAndSettle();
      expect(state.isFront, true); // should not have turned by tapping

      state.toggleCard();
      await tester.pumpAndSettle();
      expect(state.isFront, false);
    });
  });
}
