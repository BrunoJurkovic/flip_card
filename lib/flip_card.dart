library flip_card;

import 'dart:async';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';

import 'flip_transition.dart';

enum CardSide {
  front,
  back,
}

enum Fill { none, front, back }

extension on TickerFuture {
  Future<void> get complete {
    final completer = Completer();
    void thunk(value) {
      completer.complete();
    }

    orCancel.then(thunk, onError: thunk);
    return completer.future;
  }
}

class FlipCard extends StatefulWidget {
  const FlipCard({
    Key? key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 500),
    this.onFlip,
    this.onFlipDone,
    this.direction = Axis.horizontal,
    this.controller,
    this.flipOnTouch = true,
    this.alignment = Alignment.center,
    this.fill = Fill.none,
    this.initialSide = CardSide.front,
    this.autoFlipDuration,
  }) : super(key: key);

  /// The initially shown side of the card
  final CardSide initialSide;

  /// The alignment of [front] and [back]
  final Alignment alignment;

  /// If the value is set, the flip effect will work automatically after the specified duration.
  final Duration? autoFlipDuration;

  /// The widget rendered on the front side
  final Widget front;

  /// The widget rendered on the back side
  final Widget back;

  /// Assign a controller to the [FlipCard] to control it programmatically
  ///
  /// {@macro flip_card_controller.example}
  final FlipCardController? controller;

  /// The animation [Axis] of the card
  final Axis direction;

  /// Whether to fill a side of the card relative to the other
  final Fill fill;

  /// When enabled, the card will flip automatically when touched. This behavior
  /// can be disabled if this is not desired. To manually flip a card from your
  /// code, you could do this:
  ///```dart
  /// GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return FlipCard(
  ///     key: cardKey,
  ///     flipOnTouch: false,
  ///     front: Container(
  ///       child: RaisedButton(
  ///         onPressed: () => cardKey.currentState.toggleCard(),
  ///         child: Text('Toggle'),
  ///       ),
  ///     ),
  ///     back: Container(
  ///       child: Text('Back'),
  ///     ),
  ///   );
  /// }
  ///```
  final bool flipOnTouch;

  /// This callback is triggered when the card flipping is started
  final VoidCallback? onFlip;

  /// This callback is triggered when the card flipping is completed
  /// with the final [CardSide]
  final void Function(CardSide side)? onFlipDone;

  /// The [Duration] a turn animation will take.
  final Duration duration;

  @override
  State<StatefulWidget> createState() => FlipCardState();
}

class FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.duration != oldWidget.duration) {
      controller.duration = widget.duration;
    }

    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller?.state == this) {
        oldWidget.controller?.state = null;
      }

      widget.controller?.state = this;
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      value: widget.initialSide == CardSide.front ? 0.0 : 1.0,
      duration: widget.duration,
      vsync: this,
    );

    widget.controller?.state = this;

    if (widget.autoFlipDuration != null) {
      Future.delayed(widget.autoFlipDuration!, flip);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    widget.controller?.state = null;
    super.dispose();
  }

  /// {@template flip_card.FlipCardState.flip}
  /// Flips the card or reverses the direction of the current animation
  ///
  /// This function returns a future that will complete when animation is done
  /// {@endtemplate}
  Future<void> flip() async {
    if (!mounted) return;
    widget.onFlip?.call();

    switch (controller.status) {
      case AnimationStatus.dismissed:
      case AnimationStatus.reverse:
        await controller.forward().complete;
        widget.onFlipDone?.call(CardSide.back);
        break;
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        await controller.reverse().complete;
        widget.onFlipDone?.call(CardSide.front);
        break;
    }
  }

  /// {@template flip_card.FlipCardState.flipWithoutAnimation}
  /// Flip the card without playing an animation.
  ///
  /// This will cancel any ongoing animation.
  /// {@endtemplate}
  void flipWithoutAnimation() {
    controller.stop();
    widget.onFlip?.call();

    switch (controller.status) {
      case AnimationStatus.dismissed:
      case AnimationStatus.reverse:
        controller.value = 1.0;
        widget.onFlipDone?.call(CardSide.back);
        break;
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        controller.value = 0.0;
        widget.onFlipDone?.call(CardSide.front);
        break;
    }
  }

  /// {@template flip_card.FlipCardState.skew}
  /// Skew the card by amount percentage (0 - 1.0)
  ///
  /// This can be used with a MouseReagion to indicate that the card can
  /// be flipped. skew(0) to go back to original.
  ///
  /// This function returns a future that resolves when animation
  /// completes
  /// {@endtemplate}
  Future<void> skew(double target, {Duration? duration, Curve? curve}) async {
    assert(0 <= target && target <= 1);

    if (target > controller.value) {
      await controller.animateTo(
        target,
        duration: duration,
        curve: curve ?? Curves.linear,
      );
    } else {
      await controller.animateBack(
        target,
        duration: duration,
        curve: curve ?? Curves.linear,
      );
    }
  }

  /// {@template flip_card.FlipCardState.hint}
  /// Triggers a flip animation to [target] and back to 0 and completes in [duration].
  ///
  /// Calling [hint] when animating or when back side of the card is showed
  /// does nothing
  ///
  /// This function returns a future that resolves when animation
  /// completes
  /// {@endtemplate}
  Future<void> hint({
    double target = 0.2,
    Duration? duration,
    Curve curveTo = Curves.easeInOut,
    Curve curveBack = Curves.easeInOut,
  }) async {
    if (controller.status != AnimationStatus.dismissed) return;

    duration = duration ?? controller.duration!;
    final halfDuration =
        Duration(milliseconds: (duration.inMilliseconds / 2).round());

    try {
      await controller.animateTo(
        target,
        duration: halfDuration,
        curve: curveTo,
      );
    } finally {
      await controller.animateBack(
        0,
        duration: halfDuration,
        curve: curveBack,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = FlipTransition(
      front: widget.front,
      back: widget.back,
      animation: controller,
      direction: widget.direction,
      fill: widget.fill,
      alignment: widget.alignment,
    );

    /// if we need to flip the card on taps, wrap the content
    if (widget.flipOnTouch) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: flip,
        child: child,
      );
    }

    return child;
  }
}
