import 'dart:math';

import 'package:art/common/wave.dart';
import 'package:art/pages/rings/ring_painter.dart';
import 'package:flutter/material.dart';

/// The widget used to animate and style the rings.
class AnimatedRings extends StatefulWidget {
  /// The constructor for the [AnimatedRings] class
  const AnimatedRings({
    required this.rings,
    required this.radius,
    required this.size,
    required this.ringsColor,
    required this.ringsColorOpacity,
    required this.fromPeriod,
    required this.toPeriod,
    required this.waves,
    super.key,
  });

  /// The number of rings
  final int rings;

  /// The radius of the entire rings painter
  final double radius;

  /// The size for the entire rings painter
  final Size size;

  /// The color of the rings
  final Color ringsColor;

  /// The opacity for the rings color
  final double ringsColorOpacity;

  /// The start period value. Used to generate a random value starting from [fromPeriod]
  final double fromPeriod;

  /// The start period value. Used to generate a random value ending in [toPeriod]
  final double toPeriod;

  final List<List<Wave>> waves;

  @override
  State<AnimatedRings> createState() => _AnimatedRingsState();
}

class _AnimatedRingsState extends State<AnimatedRings>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  double? rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
    );

    // If there is more than 1 ring, calculate the rotation for each one
    if (widget.waves.length > 1) {
      rotation = 360 / widget.waves.length;
    }
    _controller.repeat(reverse: false); // <--
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) => CustomPaint(
        painter: RingPainter(
          controller: _controller,
          rings: widget.waves,
          radius: widget.radius,
          ringColor: widget.ringsColor,
          ringsColorOpacity: widget.ringsColorOpacity,
          rotation: rotation,
        ),
      ),
    );
  }
}
