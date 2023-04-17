import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class FlipCardController {
  /// The internal widget state.
  /// Use only if you know what you're doing!
  FlipCardState? state;

  /// The underlying AnimationController.
  /// Use only if you know what you're doing!
  AnimationController get controller {
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
  Future<void> skew(double target, {Duration? duration, Curve? curve}) async {
    assert(0 <= target && target <= 1);

    // final target = state!.isFront ? amount : 1 - amount;
    if (target > controller.value) {
      await controller.animateTo(
        target,
        duration: duration,
        curve: curve ?? Curves.linear,
      );
    } else {
      await controller.animateBack(
        target,
        duration: duration,
        curve: curve ?? Curves.linear,
      );
    }
  }

  /// Triggers a flip animation to [target] that reverses half time of [duration] duration
  /// and completes in [duration].
  /// If awaited, returns after animation completes.
  Future<void> hint({
    double target = 0.2,
    Duration? duration,
    Curve curveTo = Curves.easeInOut,
    Curve curveBack = Curves.easeInOut,
  }) async {
    if (controller.status != AnimationStatus.dismissed) return;

    duration = duration ?? controller.duration!;
    final halfDuration =
        Duration(milliseconds: (duration.inMilliseconds / 2).round());

    try {
      await controller.animateTo(
        target,
        duration: halfDuration,
        curve: curveTo,
      );
    } finally {
      await controller.animateBack(
        0,
        duration: halfDuration,
        curve: curveBack,
      );
    }
  }
}
