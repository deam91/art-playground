import 'dart:math';
import 'package:art/common/wave.dart';
import 'package:fast_noise/fast_noise.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

/// Class used to paint the rings by joining a series of waves for creating a
/// single custom wave, following a circle shape.
class RingPainter extends CustomPainter {
  /// The constructor for the [RingPainter] class
  RingPainter({
    required this.controller,
    required this.rings,
    this.radius = 80,
    this.ringColor = Colors.lightBlue,
    this.ringsColorOpacity = .3,
    this.rotation,
  }) : super(repaint: controller) {
    perlinNoise = PerlinNoise(
      seed: 800,
      octaves: 8,
      frequency: .1,
    );
  }

  /// The animation controller
  final Animation<double> controller;

  /// The radius of the entire rings painter
  final double radius;

  /// The color of the rings
  final Color ringColor;

  /// The opacity for the rings color
  final double ringsColorOpacity;

  /// The number of ring waves to paint
  List<List<Wave>> rings = [];

  /// The rotation for each ring
  final double? rotation;
  double rot = .0;

  late final PerlinNoise perlinNoise;

  num map(num value, num domainMin, num domainMax, num rangeMin, num rangeMax) {
    return (value - domainMin) *
            (rangeMax - rangeMin) /
            (domainMax - domainMin) +
        rangeMin;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ringColor.withOpacity(ringsColorOpacity)
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;
    var previousOffset = Offset.zero;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.save();
    for (var l = 0; l < rings.length; l++) {
      final phaseX = l % 2 == 0 ? -.3 : 0;
      final phaseY = l % 2 != 0 ? -.3 : 0;
      final color = Color.lerp(ringColor.withOpacity(.2),
          ringColor.withOpacity(.9), map(l, 0, rings.length, 0, 1).toDouble());
      paint.color = color!.withOpacity(.8);
      for (var i = .0; i < pi * 2; i += vm.radians(1)) {
        var xoff = map(cos(i), -1, 1, 0, 10).toDouble();
        var yoff = map(sin(i), -1, 1, 0, 10).toDouble();
        //
        final noise = perlinNoise.getPerlin2(xoff.toDouble(), yoff.toDouble());
        final noiseValue = map(noise, -1, 1, 0, 2);
        final r = map(noiseValue, 0, 1, radius - 20, radius);

        final x = r * cos(i + phaseX + (vm.radians(rotation!) * l));
        var y = r * sin(i + phaseY + (vm.radians(rotation!) * l));

        for (final wave in rings[l]) {
          y += wave.evaluateSin(x, controller.value * r);
        }
        final offset = Offset(x, y);
        if (previousOffset == Offset.zero) {
          previousOffset = offset;
        }

        canvas.drawLine(
          previousOffset,
          offset,
          paint,
        );
        previousOffset = offset;
      }
      previousOffset = Offset.zero;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) => true;
}
