import 'dart:math';

import 'package:flutter/material.dart';

import 'flip_card.dart';

Widget _fill(Widget child) => Positioned.fill(child: child);
Widget _noop(Widget child) => child;

/// The transition used internally by [FlipCard]
///
/// You obtain more control by providing your on [Animation]
/// at the cost of built-in methods like [FlipCardState.flip]
class FlipCardTransition extends StatefulWidget {
  const FlipCardTransition({
    super.key,
    required this.front,
    required this.back,
    required this.animation,
    this.direction = Axis.horizontal,
    this.fill = Fill.none,
    this.alignment = Alignment.center,
    this.frontAnimator,
    this.backAnimator,
    this.filterQuality,
  });

  /// {@template flip_card.FlipCardTransition.front}
  /// The widget rendered on the front side
  /// {@endtemplate}
  final Widget front;

  /// {@template flip_card.FlipCardTransition.back}
  /// The widget rendered on the front side
  /// {@endtemplate}
  final Widget back;

  /// The [Animation] that controls the flip card
  final Animation<double> animation;

  /// {@template flip_card.FlipCardTransition.direction}
  /// The animation [Axis] of the card
  /// {@endtemplate}
  final Axis direction;

  /// {@template flip_card.FlipCardTransition.fill}
  /// Whether to fill a side of the card relative to the other
  /// {@endtemplate}
  final Fill fill;

  /// {@template flip_card.FlipCardTransition.alignment}
  /// How to align the [front] and [back] in the card
  /// {@endtemplate}
  final Alignment alignment;

  /// {@macro flip_card.FlipTransition.filterQuality}
  final FilterQuality? filterQuality;

  /// The [Animatable] used to animate the front side
  final Animatable<double>? frontAnimator;

  /// The [Animatable] used to animate the back side
  final Animatable<double>? backAnimator;

  /// The default [frontAnimator]
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

  /// The default [backAnimator]
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
    _currentSide = CardSide.fromAnimationStatus(widget.animation.status);
    widget.animation.addStatusListener(_handleChange);
  }

  @override
  void didUpdateWidget(covariant FlipCardTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation.removeStatusListener(_handleChange);
      widget.animation.addStatusListener(_handleChange);
      _currentSide = CardSide.fromAnimationStatus(widget.animation.status);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.animation.removeStatusListener(_handleChange);
  }

  void _handleChange(AnimationStatus status) {
    final newSide = CardSide.fromAnimationStatus(status);
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
      child: FlipTransition(
        animation: isFront
            ? (widget.frontAnimator ?? FlipCardTransition.defaultFrontAnimator)
                .animate(widget.animation)
            : (widget.backAnimator ?? FlipCardTransition.defaultBackAnimator)
                .animate(widget.animation),
        direction: widget.direction,
        filterQuality: widget.filterQuality,
        child: child,
      ),
    );
  }
}

/// The transition used by each side of the [FlipCardTransition]
///
/// This applies a rotation [Transform] in the given [direction]
/// where the angle is [Animation.value]
class FlipTransition extends AnimatedWidget {
  const FlipTransition({
    super.key,
    required this.child,
    required this.animation,
    required this.direction,
    required this.filterQuality,
  }) : super(listenable: animation);

  /// The [Animation] that controls this transition
  final Animation<double> animation;

  /// The widget being animated
  final Widget child;

  /// The direction of the flip
  final Axis direction;

  /// {@template flip_card.FlipTransition.filterQuality}
  /// The filter quality for the internal [Transform] on the card.
  /// Setting this to [FilterQuality.none] can prevent vertical lines but might lead to other issues.
  /// {@endtemplate}
  final FilterQuality? filterQuality;

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
      alignment: FractionalOffset.center,
      filterQuality: filterQuality,
      child: child,
    );
  }
}
