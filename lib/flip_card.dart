library flip_card;

import 'dart:async';
import 'dart:math';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';

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

class AnimationCard extends AnimatedWidget {
  const AnimationCard({
    Key? key,
    required this.child,
    required this.animation,
    required this.direction,
  }) : super(key: key, listenable: animation);

  final Animation<double> animation;
  final Widget child;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final transform = Matrix4.identity();
    transform.setEntry(3, 2, 0.001);
    switch (direction) {
      case Axis.horizontal:
        transform.rotateY(animation.value);
        break;
      case Axis.vertical:
        transform.rotateX(animation.value);
        break;
    }

    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: child,
    );
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

  final Alignment alignment;

  /// If the value is set, the flip effect will work automatically after the specified duration.
  final Duration? autoFlipDuration;

  final Widget front;
  final Widget back;
  final FlipCardController? controller;
  final Axis direction;
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

  final VoidCallback? onFlip;
  final void Function(CardSide side)? onFlipDone;
  final CardSide initialSide;

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

    if (widget.controller?.state != this) {
      widget.controller?.state = this;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    widget.controller?.state = null;
    super.dispose();
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

  /// Flips the card or reverses the direction of the current animation
  ///
  /// This function will complete when animation is done
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

  /// Flip the card without playing an animation.
  ///`
  /// This cancels any ongoing animation.
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

  @override
  Widget build(BuildContext context) {
    final child = FlipCardTransition(
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

Widget _fill(Widget child) => Positioned.fill(child: child);
Widget _noop(Widget child) => child;

class FlipCardTransition extends StatefulWidget {
  const FlipCardTransition({
    Key? key,
    required this.front,
    required this.back,
    required this.animation,
    this.direction = Axis.horizontal,
    this.fill = Fill.none,
    this.alignment = Alignment.center,
    this.frontAnimator,
    this.backAnimator,
  }) : super(key: key);

  final Widget front;
  final Widget back;
  final Animation<double> animation;
  final Axis direction;
  final Fill fill;
  final Alignment alignment;

  final Animatable<double>? frontAnimator;
  final Animatable<double>? backAnimator;

  static final defaultFrontAnimator = TweenSequence(
    [
      TweenSequenceItem<double>(
        tween: Tween(begin: 0.0, end: pi / 2).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 50.0,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(pi / 2),
        weight: 50.0,
      ),
    ],
  );

  static final defaultBackAnimator = TweenSequence(
    [
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(pi / 2),
        weight: 50.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween(begin: -pi / 2, end: 0.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 50.0,
      ),
    ],
  );

  @override
  State<FlipCardTransition> createState() => _FlipCardTransitionState();
}

class _FlipCardTransitionState extends State<FlipCardTransition> {
  late CardSide _currentSide;

  @override
  void initState() {
    super.initState();
    _currentSide = _getSideFor(widget.animation.status);
    widget.animation.addStatusListener(_handleChange);
  }

  @override
  void didUpdateWidget(covariant FlipCardTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation.removeStatusListener(_handleChange);
      widget.animation.addStatusListener(_handleChange);
      _currentSide = _getSideFor(widget.animation.status);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.animation.removeStatusListener(_handleChange);
  }

  CardSide _getSideFor(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
      case AnimationStatus.reverse:
        return CardSide.front;
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        return CardSide.back;
    }
  }

  void _handleChange(AnimationStatus status) {
    final newSide = _getSideFor(status);
    if (newSide != _currentSide) {
      setState(() {
        _currentSide = newSide;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final frontPositioning = widget.fill == Fill.front ? _fill : _noop;
    final backPositioning = widget.fill == Fill.back ? _fill : _noop;

    return Stack(
      alignment: widget.alignment,
      fit: StackFit.passthrough,
      children: <Widget>[
        frontPositioning(_buildContent(child: widget.front)),
        backPositioning(_buildContent(child: widget.back)),
      ],
    );
  }

  Widget _buildContent({required Widget child}) {
    final isFront = child == widget.front;
    final showingFront = _currentSide == CardSide.front;

    /// pointer events that would reach the backside of the card should be
    /// ignored
    return IgnorePointer(
      /// absorb the front card when the background is active (!isFront),
      /// absorb the background when the front is active
      ignoring: isFront ? !showingFront : showingFront,
      child: AnimationCard(
        animation: isFront
            ? (widget.frontAnimator ?? FlipCardTransition.defaultFrontAnimator)
                .animate(widget.animation)
            : (widget.backAnimator ?? FlipCardTransition.defaultBackAnimator)
                .animate(widget.animation),
        direction: widget.direction,
        child: child,
      ),
    );
  }
}
