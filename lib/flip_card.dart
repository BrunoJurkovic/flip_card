library flip_card;

import 'dart:math';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';

enum CardSide {
  front,
  back,
}

enum Fill { none, front, back }

class AnimationCard extends StatelessWidget {
  const AnimationCard({
    Key? key,
    required this.child,
    required this.animation,
    required this.direction,
  }) : super(key: key);

  final Animation<double> animation;
  final Widget child;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
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
          filterQuality: FilterQuality.none,
          alignment: FractionalOffset.center,
          child: child,
        );
      },
      child: child,
    );
  }
}

typedef BoolCallback = void Function(bool isFront);

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
    this.side = CardSide.front,
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
  final BoolCallback? onFlipDone;
  final CardSide side;

  /// The [Duration] a turn animation will take.
  final Duration duration;

  @override
  State<StatefulWidget> createState() => FlipCardState();
}

class FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late Animation<double> _backRotation;
  late Animation<double> _frontRotation;

  late bool isFront = widget.side == CardSide.front;

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
      value: isFront ? 0.0 : 1.0,
      duration: widget.duration,
      vsync: this,
    );
    _frontRotation = TweenSequence(
      [
        TweenSequenceItem<double>(
          tween: Tween(begin: 0.0, end: pi / 2)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
      ],
    ).animate(controller);
    _backRotation = TweenSequence(
      [
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween(begin: -pi / 2, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50.0,
        ),
      ],
    ).animate(controller);

    widget.controller?.state = this;

    if (widget.autoFlipDuration != null) {
      Future.delayed(widget.autoFlipDuration!, toggleCard);
    }
  }

  /// Flip the card
  /// If awaited, returns after animation completes.
  Future<void> toggleCard() async {
    if (!mounted) return;

    widget.onFlip?.call();

    final isFrontBefore = isFront;
    controller.duration = widget.duration;

    final animation = isFront ? controller.forward() : controller.reverse();
    animation.whenComplete(() {
      if (widget.onFlipDone != null) widget.onFlipDone!(isFront);
      if (!mounted) return;
      setState(() => isFront = !isFrontBefore);
    });
  }

  /// Flip the card without playing an animation.
  /// This cancels any ongoing animation.
  void toggleCardWithoutAnimation() {
    controller.stop();

    widget.onFlip?.call();

    if (widget.onFlipDone != null) widget.onFlipDone!(isFront);

    setState(() {
      isFront = !isFront;
      controller.value = isFront ? 0.0 : 1.0;
    });
  }

  Widget _buildContent({required bool front}) {
    /// pointer events that would reach the backside of the card should be
    /// ignored
    return IgnorePointer(
      /// absorb the front card when the background is active (!isFront),
      /// absorb the background when the front is active
      ignoring: front ? !isFront : isFront,
      child: AnimationCard(
        animation: front ? _frontRotation : _backRotation,
        direction: widget.direction,
        child: front ? widget.front : widget.back,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final frontPositioning = widget.fill == Fill.front ? _fill : _noop;
    final backPositioning = widget.fill == Fill.back ? _fill : _noop;

    final child = Stack(
      alignment: widget.alignment,
      fit: StackFit.passthrough,
      children: <Widget>[
        frontPositioning(_buildContent(front: true)),
        backPositioning(_buildContent(front: false)),
      ],
    );

    /// if we need to flip the card on taps, wrap the content
    if (widget.flipOnTouch) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: toggleCard,
        child: child,
      );
    }

    return child;
  }
}

Widget _fill(Widget child) => Positioned.fill(child: child);
Widget _noop(Widget child) => child;
