import 'dart:async';

import 'package:flutter/material.dart';

import 'flip_card.dart';

/// A controller used with [FlipCard] to control it programmatically
///
/// {@template flip_card_controller.example}
/// ## Example
///
/// Inside a stateful widgets state do the following:
///
/// ```dart
/// late FlipCardController controller = FlipCardController();
///
/// @override
/// Widget build(BuildContext context) {
///   return FlipCard(
///     controller: controller,
///     flipOnTouch: false,
///     front: RaisedButton(
///       onPressed: controller.flip,
///       child: const Text('Front'),
///     ),
///     back: RaisedButton(
///       onPressed: controller.flip,
///       child: const Text('Back'),
///     ),
///   );
/// }
/// ```
/// {@endtemplate}
class FlipCardController {
  FlipCardState? _internalState;

  /// The internal widget state. Use only if you know what you're doing!
  ///
  /// This will throw an [AssertionError] if controller has not been
  /// assigned to a [FlipCard] widget or state has not been initialized
  FlipCardState get state {
    assert(
      _internalState != null,
      'Controller not attached to any FlipCard. Did you forget to pass the controller to the FlipCard?',
    );
    return _internalState!;
  }

  /// Set the internal state
  set state(FlipCardState? value) => _internalState = value;

  /// {@macro flip_card.FlipCardState.flip}
  Future<void> flip({CardSide? targetSide}) async =>
      await state.flip(targetSide);

  /// {@macro flip_card.FlipCardState.flipWithoutAnimation}
  void flipWithoutAnimation([CardSide? targetSide]) =>
      state.flipWithoutAnimation(targetSide);

  /// {@macro flip_card.FlipCardState.skew}
  Future<void> skew(
    double target, {
    Duration? duration,
    Curve? curve,
  }) async =>
      await state.skew(
        target,
        duration: duration,
        curve: curve,
      );

  /// {@macro flip_card.FlipCardState.hint}
  Future<void> hint({
    double target = 0.2,
    Duration? duration,
    Curve curveTo = Curves.easeInOut,
    Curve curveBack = Curves.easeInOut,
  }) async =>
      await state.hint(
        target: target,
        duration: duration,
        curveTo: curveTo,
        curveBack: curveBack,
      );
}
