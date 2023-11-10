import 'dart:math';

import 'package:flutter/material.dart';

/// Class used to paint the rings by joining a series of waves for creating a
/// single custom wave, following a circle shape.
class RingPainter extends CustomPainter {
  /// The constructor for the [RingPainter] class
  ///
  /// Accepts an animation [controller], the amount of [rings], the [radius] of
  /// the entire rings painter, a [ringSpace] space between each ring,
  /// a [ringColor] color of the rings, the [ringsColorOpacity] opacity for the
  /// rings, and the [rotation] for each ring.
  ///
  RingPainter({
    required this.controller,
  }) : super(repaint: controller);

  double a = 10;
  double b = 28;
  double c = 8 / 3;
  double x = 0.01;
  double y = 0;
  double z = 0;

  /// The animation controller
  final Animation<double> controller;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    var previousOffset = Offset.zero;

    // for (var l = 0; l < rings.length; l++) {
    //   for (var i = -smallDegree; i < pi * 2; i += smallDegree) {
    //     final x = savedRadius * cos(i + degreeToRadian(rotation!) * l);
    //     var y = savedRadius * sin(i + degreeToRadian(rotation!) * l);

    //     for (final wave in rings[l]) {
    //       y += wave.evaluateSin(x, controller.value * savedRadius);
    //     }
    //     final offset = Offset(
    //       x + size.width / 2,
    //       y + size.height / 2,
    //     );
    //     if (previousOffset == Offset.zero) {
    //       previousOffset = offset;
    //     }

    //     canvas.drawLine(
    //       previousOffset,
    //       offset,
    //       paint,
    //     );
    //     previousOffset = offset;
    //   }
    //   previousOffset = Offset.zero;
    // }
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) => true;
}
