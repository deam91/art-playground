import 'dart:math';

/// The class used to represent a wave. Accepts an [amplitude], a [period], and a [phase].
/// The [phase] is the offset you want to be the 0 value, shifting everything over for the rest of the period;
/// the [period] is the width of the wave, and the [amplitude] is
/// how big the wave is gonna be along the `y` coordinate.
///
/// e.g. if the height is 200, the [amplitude] will be between 100 and -100, so [amplitude] = 100.
class Wave {
  Wave({
    required this.amplitude,
    required this.period,
    this.phase = 0.0,
  });
  final double amplitude;
  final double period;
  double phase;

  /// Evaluate the [x] and the [animation] value (phase). Returns the corresponding `y` coordinate.
  /// Follows the formula ``y = sin(phase + 2 * pi * x / period) * amplitude``.
  ///
  double evaluateSin(double x, double animation) {
    return sin(animation + 2 * pi * x / period) * amplitude;
  }
}
