import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class FlipCardController {
  /// The internal widget state.
  /// Use only if you know what you're doing!
  FlipCardState? state;

  /// The underlying AnimationController.
  /// Use only if you know what you're doing!
  AnimationController? get controller {
    assert(state != null,
        'Controller not attached to any FlipCard. Did you forget to pass the controller to the FlipCard?');
    return state!.controller;
  }

  /// Flip the card
  /// If awaited, returns after animation completes.
  Future<void> toggleCard() async => await state?.toggleCard();

  /// Flip the card without playing an animation.
  /// This cancels any ongoing animation.
  void toggleCardWithoutAnimation() => state?.toggleCardWithoutAnimation();

  /// Skew by amount percentage (0 - 1.0)
  /// This can be used with a MouseReagion to indicate that the card can
  /// be flipped. skew(0) to go back to original.
  /// If awaited, returns after animation completes.
  Future<void> skew(double amount, {Duration? duration, Curve? curve}) async {
    assert(0 <= amount && amount <= 1);

    final target = state!.isFront ? amount : 1 - amount;
    await controller
        ?.animateTo(target, duration: duration, curve: curve ?? Curves.linear)
        .asStream()
        .first;
  }

  /// Triggers a flip animation that reverses after the duration
  /// and will run for `total`
  /// If awaited, returns after animation completes.
  Future<void> hint({Duration? duration, Duration? total}) async {
    assert(controller is AnimationController);
    if (!(controller is AnimationController)) return;

    if (controller!.isAnimating || controller!.value != 0) return;

    final durationTotal = total ?? controller!.duration;

    final completer = Completer();

    Duration? original = controller!.duration;
    controller!.duration = durationTotal;
    controller!.forward();

    final durationFlipBack = duration ?? const Duration(milliseconds: 150);

    Timer(durationFlipBack, () {
      controller!.reverse().whenComplete(() {
        completer.complete();
      });
      controller!.duration = original;
    });

    await completer.future;
  }
}
