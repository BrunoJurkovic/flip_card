// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flip_card/flip_card.dart';

void main() {
  testWidgets('smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final frontKey = Key('front');
    final backKey = Key('back');
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: FlipCard(
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

  testWidgets('background interactions are ignored',
      (WidgetTester tester) async {
    // check that background touches are blocked
    bool backgroundTouched = false;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: new FlipCard(
          front: Text('front'),
          back: TextButton(
            onPressed: () => backgroundTouched = true,
            child: Text('back'),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton), warnIfMissed: false);
    expect(backgroundTouched, false);
  });

  testWidgets('card initialized with back side', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: new FlipCard(
          front: Text('front'),
          back: Text('back'),
          side: CardSide.BACK,
        ),
      ),
    );
    final state = tester.state<FlipCardState>(find.byType(FlipCard));

    expect(state.isFront, isFalse);

    await tester.tap(find.byType(FlipCard));
    await tester.pumpAndSettle();

    expect(state.isFront, isTrue);
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

      await state.toggleCard();
      await tester.pumpAndSettle();
      expect(state.isFront, false);
    });

    testWidgets('manually via controller', (WidgetTester tester) async {
      final controller = FlipCardController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: new FlipCard(
            controller: controller,
            flipOnTouch: false,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );
      // final state = tester.state<FlipCardState>(find.byType(FlipCard));

      await controller.toggleCard();
      await tester.pumpAndSettle();

      expect(controller.state?.isFront, false);
    });

    testWidgets('manually via controller without animation',
        (WidgetTester tester) async {
      final controller = FlipCardController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: new FlipCard(
            controller: controller,
            flipOnTouch: false,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      controller.toggleCardWithoutAnimation();
      await tester.pump();

      expect(controller.state?.isFront, false);
    });
  });

  group('skew', () {
    testWidgets('skew keeps isFront unchanged', (WidgetTester tester) async {
      final controller = FlipCardController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: new FlipCard(
            controller: controller,
            flipOnTouch: false,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardState>(find.byType(FlipCard));

      await controller.skew(0.5);

      await tester.pumpAndSettle();
      expect(state.isFront, true);
    });
  });

  group('hint', () {
    testWidgets('hint keeps isFront unchanged', (WidgetTester tester) async {
      final controller = FlipCardController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: new FlipCard(
            controller: controller,
            flipOnTouch: false,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardState>(find.byType(FlipCard));

      await controller.hint(
          duration: Duration(seconds: 1), total: Duration(seconds: 2));

      await tester.pumpAndSettle();
      expect(state.isFront, true);
    });
  });
}
