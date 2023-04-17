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

  group('initial side with', () {
    testWidgets('front side', (widgetTester) async {
      await widgetTester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCard(
            initialSide: CardSide.front,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = widgetTester.state<FlipCardState>(find.byType(FlipCard));
      expect(state.controller.status, AnimationStatus.dismissed);

      await widgetTester.tap(find.byType(FlipCard));
      await widgetTester.pumpAndSettle();

      expect(state.controller.status, AnimationStatus.completed);
    });

    testWidgets('back side', (widgetTester) async {
      await widgetTester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCard(
            initialSide: CardSide.back,
            front: Text('front'),
            back: Text('back'),
          ),
        ),
      );

      final state = widgetTester.state<FlipCardState>(find.byType(FlipCard));
      expect(state.controller.status, AnimationStatus.completed);

      await widgetTester.tap(find.byType(FlipCard));
      await widgetTester.pumpAndSettle();

      expect(state.controller.status, AnimationStatus.dismissed);
    });
  });

  group('cards flip', () {
    testWidgets('automatically', (WidgetTester tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FlipCard(
            front: Text('front'),
            back: Text('back'),
            flipOnTouch: true,
          ),
        ),
      );
      final state = tester.state<FlipCardState>(find.byType(FlipCard));
      expect(state.controller.status, AnimationStatus.dismissed);

      await tester.tap(find.byType(FlipCard));
      await tester.pumpAndSettle();

      expect(state.controller.status, AnimationStatus.completed);
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
      expect(
        state.controller.status,
        AnimationStatus.dismissed,
        reason: 'Should not have turned by tapping',
      );

      final future = state.toggleCard();
      await tester.pumpAndSettle();
      await future;
      await tester.pumpAndSettle();

      expect(
        state.controller.status,
        AnimationStatus.completed,
        reason: 'Should have turned by manually calling toggleCard',
      );
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

      final future = controller.toggleCard();
      await tester.pumpAndSettle();
      await future;
      await tester.pumpAndSettle();

      expect(controller.state?.controller.status, AnimationStatus.completed);
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

      expect(controller.state?.controller.status, AnimationStatus.completed);
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
      final future = controller.skew(0.2);
      await tester.pumpAndSettle();
      await future;
      await tester.pumpAndSettle();

      expect(state.controller.status, AnimationStatus.completed);
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
      final future = controller.hint();
      await tester.pumpAndSettle();
      await future;
      await tester.pumpAndSettle();

      expect(state.controller.status, AnimationStatus.dismissed);
    });
  });
}
