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
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: FlipCard(
        front: Container(
          key: const Key('front'),
          child: const Text('front'),
        ),
        back: Container(
          key: const Key('back'),
          child: const Text('back'),
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
        child: FlipCard(
          front: const Text('front'),
          back: TextButton(
            onPressed: () => backgroundTouched = true,
            child: const Text('back'),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextButton), warnIfMissed: false);
    expect(backgroundTouched, false);
  });

  testWidgets('card initialized with back side', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: FlipCard(
          front: Text('front'),
          back: Text('back'),
          side: CardSide.back,
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
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCard(
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
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCard(
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
          child: FlipCard(
            controller: controller,
            flipOnTouch: false,
            front: const Text('front'),
            back: const Text('back'),
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
          child: FlipCard(
            controller: controller,
            flipOnTouch: false,
            front: const Text('front'),
            back: const Text('back'),
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
          child: FlipCard(
            controller: controller,
            flipOnTouch: false,
            front: const Text('front'),
            back: const Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardState>(find.byType(FlipCard));
      expect(state.isFront, true, reason: 'Expect initial isFront to be true');

      controller.skew(0.2);
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
          child: FlipCard(
            controller: controller,
            flipOnTouch: false,
            front: const Text('front'),
            back: const Text('back'),
          ),
        ),
      );

      final state = tester.state<FlipCardState>(find.byType(FlipCard));
      expect(state.isFront, true, reason: 'Expect initial isFront to be true');

      controller.hint(target: 0.2, duration: const Duration(milliseconds: 200));

      await tester.pumpAndSettle();
      expect(state.isFront, true);
    });
  });
}
