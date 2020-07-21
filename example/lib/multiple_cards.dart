import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class MultipleCards extends AbstractFlipCard {
  const MultipleCards(
      {Key key, speed = 500, onFlip, onFlipDone, direction, flipOnTouch = true})
      : super(
            key: key,
            speed: speed,
            onFlip: onFlip,
            onFlipDone: onFlipDone,
            direction: direction,
            flipOnTouch: flipOnTouch);
  State<StatefulWidget> createState() {
    return MultipleCardsState();
  }
}

class MultipleCardsState extends AbstractFlipCardState<MultipleCards> {
  @override
  Widget build(BuildContext context) {
    final front = Container(
      decoration: BoxDecoration(
        color: Color(0xFF006666),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Front', style: Theme.of(context).textTheme.headline),
          Text('Click here to flip back',
              style: Theme.of(context).textTheme.body1),
        ],
      ),
    );
    final back = Container(
      decoration: BoxDecoration(
        color: Color(0xFF006666),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Back', style: Theme.of(context).textTheme.headline),
          Text('Click here to flip front',
              style: Theme.of(context).textTheme.body1),
        ],
      ),
    );
    final child1 = buildCard(front: front, back: back);
    final child2 = buildCard(front: front, back: back);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: child1,
        ),
        Expanded(
          child: child2,
        ),
      ],
    );
  }
}
