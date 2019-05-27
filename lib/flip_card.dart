library flip_card;

import 'dart:math';

import 'package:flutter/material.dart';

enum FlipDirection {
  VERTICAL,
  HORIZONTAL,
}

class AnimationCard extends StatelessWidget {
  AnimationCard({this.child, this.animation, this.direction});

  final Widget child;
  final Animation<double> animation;
  final FlipDirection direction;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        var transform = Matrix4.identity();
        transform.setEntry(3, 2, 0.001);
        if (direction == FlipDirection.VERTICAL) {
          transform.rotateX(animation.value);
        } else {
          transform.rotateY(animation.value);
        }
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final int speed;
  final FlipDirection direction;
  final VoidCallback onFlip;

  const FlipCard(
      {Key key,
      @required this.front,
      @required this.back,
      this.speed = 500,
      this.onFlip,
      this.direction = FlipDirection.HORIZONTAL})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FlipCardState();
  }
}

class FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> _frontRotation;
  Animation<double> _backRotation;

  bool isFront = true;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(milliseconds: widget.speed), vsync: this);
    _frontRotation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween(begin: 0.0, end: pi / 2).chain(CurveTween(curve: Curves.linear)),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
      ],
    ).animate(controller);
    _backRotation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween(begin: -pi / 2, end: 0.0).chain(CurveTween(curve: Curves.linear)),
          weight: 50.0,
        ),
      ],
    ).animate(controller);
  }

  toggleCard() {
    if (widget.onFlip != null) {
      widget.onFlip();
    }
    if (isFront) {
      controller.forward();
    } else {
      controller.reverse();
    }

    setState(() {
      isFront = !isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleCard,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AbsorbPointer(
            absorbing: !isFront,
            child: AnimationCard(
              animation: _frontRotation,
              child: widget.front,
              direction: widget.direction,
            ),
          ),
          AbsorbPointer(
            absorbing: isFront,
            child: AnimationCard(
              animation: _backRotation,
              child: widget.back,
              direction: widget.direction,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
