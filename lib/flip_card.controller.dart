import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class FlipCardController {
  /// The internal widget state.
  /// Use only if you know what you're doing!
  FlipCardState state;

  /// The underlying AnimationController.
  /// Use only if you know what you're doing!
  AnimationController get controller => state?.controller;

  /// Flip the card
  void toggleCard() => state?.toggleCard();

  /// Skew by amount percentage (0 - 1.0)
  /// This can be used with a MouseReagion to indicate that the card can
  /// be flipped. skew(0) to go back to original.
  void skew(double amount, {Duration duration, Curve curve}) {
    assert(0 <= amount && amount <= 1);

    if (state.isFront) {
      controller?.animateTo(amount, duration: duration, curve: curve);
    } else {
      controller?.animateTo(1 - amount, duration: duration, curve: curve);
    }
  }

  /// Triggers a flip animation that reverses after the duration
  /// and will run for `total`
  void hint({Duration duration, Duration total}) {
    assert(controller is AnimationController);
    if (!(controller is AnimationController)) {
      return;
    }

    if (controller.isAnimating || controller.value != 0) return;

    Duration original = controller.duration;
    controller.duration = total ?? controller.duration;
    controller.forward();
    Timer(duration ?? const Duration(milliseconds: 150), () {
      controller.reverse();
      controller.duration = original;
    });
  }
}
