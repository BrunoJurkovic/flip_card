import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

Widget _fill(Widget child) => Positioned.fill(child: child);
Widget _noop(Widget child) => child;

class FlipTransition extends StatefulWidget {
  const FlipTransition({
    super.key,
    required this.front,
    required this.back,
    required this.animation,
    this.direction = Axis.horizontal,
    this.fill = Fill.none,
    this.alignment = Alignment.center,
    this.frontAnimator,
    this.backAnimator,
  });

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
  State<FlipTransition> createState() => _FlipTransitionState();
}

class _FlipTransitionState extends State<FlipTransition> {
  late CardSide _currentSide;

  @override
  void initState() {
    super.initState();
    _currentSide = _getSideFor(widget.animation.status);
    widget.animation.addStatusListener(_handleChange);
  }

  @override
  void didUpdateWidget(covariant FlipTransition oldWidget) {
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
            ? (widget.frontAnimator ?? FlipTransition.defaultFrontAnimator)
                .animate(widget.animation)
            : (widget.backAnimator ?? FlipTransition.defaultBackAnimator)
                .animate(widget.animation),
        direction: widget.direction,
        child: child,
      ),
    );
  }
}

class AnimationCard extends AnimatedWidget {
  const AnimationCard({
    super.key,
    required this.child,
    required this.animation,
    required this.direction,
  }) : super(listenable: animation);

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
      alignment: FractionalOffset.center,
      filterQuality: FilterQuality.none,
      child: child,
    );
  }
}
