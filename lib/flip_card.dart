library flip_card;

import 'package:flutter/material.dart';
import 'package:flip_card/abstract_flip_card.dart';

export 'package:flip_card/abstract_flip_card.dart';

class FlipCard extends AbstractFlipCard {
  final Widget front;
  final Widget back;

  const FlipCard(
      {Key key,
      @required this.front,
      @required this.back,
      speed = 500,
      onFlip,
      onFlipDone,
      direction = FlipDirection.HORIZONTAL,
      flipOnTouch = true})
      : super(
            key: key,
            speed: speed,
            onFlip: onFlip,
            onFlipDone: onFlipDone,
            direction: direction,
            flipOnTouch: flipOnTouch);

  @override
  State<StatefulWidget> createState() {
    return FlipCardState();
  }
}

class FlipCardState extends AbstractFlipCardState<FlipCard> {
  @override
  Widget build(BuildContext context) {
    final child = buildCard(front: widget.front, back: widget.back);
    return child;
  }
}
