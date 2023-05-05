# flip_card [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/fedeoo/flip_card/pulls) [![Pub Package](https://img.shields.io/pub/v/flip_card.svg)](https://pub.dartlang.org/packages/flip_card)

A component that provides a flip card animation. It could be used for hiding and showing details of a product.

<p>
  <img src="/screenshots/flip-h.gif?raw=true&v1" width="320" />
  <img src="/screenshots/flip-v.gif?raw=true&v1" width="320" />
</p>

## How to use

Import the package

```dart
import 'package:flip_card/flip_card.dart';
```

### Default

Create a flip card as shown below. By default the card is touch controlled.

You can turn of touch control by setting `flipOnTouch` to `false`.

```dart
FlipCard(
  fill: Fill.fillBack, // Fill the back side of the card to make in the same size as the front.
  direction: FlipDirection.HORIZONTAL, // default
  initialSide: CardSide.front, // The side to initially display.
  front: Container(
    child: Text('Front'),
  ),
  back: Container(
    child: Text('Back'),
  ),
)
```

### Programmatically

#### Controller (Recommended)

To control the card programmatically, you can pass a controller
when creating the card.

```dart
late FlipCardController _controller = FlipCardController();

@override
Widget build(BuildContext context) {
  return FlipCard(
    controller: _controller,
    front: ...,
    back: ...,
  );
}

void doStuff() {
  // Flip the card a bit and back to indicate that it can be flipped (for example on page load)
  _controller.hint(
    duration: const Duration(milliseconds: 400),
  );

  // Tilt the card a bit (for example when hovering)
  _controller.skew(0.2);

  // Flip the card programmatically
  _controller.flip();

  // Flip the card to front specifically
  _controller.flip(CardSide.front);

  // Flip the card without animation
  _controller.flipWithoutAnimation();
}
```

#### Global Key

You can also control the card via a global key as shown below.

This is not the recommended way.

```dart
final cardKey = GlobalKey<FlipCardState>();

@override
Widget build(BuildContext context) {
  return FlipCard(
    key: cardKey,
    flipOnTouch: false,
    front: Container(
      child: RaisedButton(
        onPressed: () => cardKey.currentState.toggleCard(),
        child: Text('Toggle'),
      ),
    ),
    back: Container(
      child: Text('Back'),
    ),
  );
}
```

### Timed

You can auto-flip the widget after a certain delay without any external triggering.

```dart
FlipCard(
  fill: Fill.back, // Fill the back side of the card to make in the same size as the front.
  direction: Axis.horizontal, // default
  initialSide: CardSide.front, // The side to initially display.
  front: Container(
    child: Text('Front'),
  ),
  back: Container(
    child: Text('Back'),
  ),
  autoFlipDuration: const Duration(seconds: 2), // The flip effect will work automatically after the 2 seconds
)
```
