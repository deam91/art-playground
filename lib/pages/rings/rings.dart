import 'dart:math';

import 'package:art/common/wave.dart';
import 'package:art/pages/rings/animated_rings.dart';
import 'package:flutter/material.dart';

/// Paint the rings by appending a series of different waves into one per ring,
/// and then drawing each ring following a circle shape.
class Rings extends StatefulWidget {
  /// The constructor for the [Rings] class
  const Rings({
    required this.child,
    this.rings = 4,
    this.radius = 80,
    this.fromPeriod = 150,
    this.toPeriod = 200,
    this.ringsColor = Colors.lightBlue,
    this.ringsColorOpacity = .4,
    super.key,
  })  : assert(
          rings <= 10,
          'The rings must less/equal to 16 to keep performance',
        ),
        assert(
          fromPeriod > 10 ||
              toPeriod > 10 ||
              fromPeriod <= 400 ||
              toPeriod <= 400,
          'The fromPeriod and toPeriod values must be between 10 and 400',
        ),
        assert(
          fromPeriod <= toPeriod,
          'The toPeriod must be bigger or equal to fromPeriod',
        );

  /// The child widget for the rings avatar.
  final Widget child;

  /// The number of rings. Defaults to 1.
  final int rings;

  /// The radius of the entire rings painter. Defaults to 80.
  final double radius;

  /// The color of the rings. Defaults to [Colors.lightBlue].
  final Color ringsColor;

  /// The start period value. Used to generate a random value starting from [fromPeriod]. Defaults to 150.
  final double fromPeriod;

  /// The end period value. Used to generate a random value ending in [toPeriod]. Defaults to 200.
  final double toPeriod;

  /// The opacity of the rings color. Defaults to 0.4.
  final double ringsColorOpacity;

  @override
  State<Rings> createState() => _RingsState();
}

class _RingsState extends State<Rings> {
  List<List<Wave>> waves = [];

  /// Create the wave objects used to build a ring.
  /// The `amplitude`, `period`, and `phase` are random values following the rules:
  ///  - `amplitude` is a random value between 0 and 4
  ///  - `period` is a random value between 100 and 200 by default. Values of `fromPeriod` and `toPeriod`
  ///  - `phase` is by default 2*pi, the phase of a wave
  List<Wave> _buildWaves() {
    final waves = <Wave>[];
    for (var i = 0; i < 5; i++) {
      final amplitude = Random().nextDouble() * 1 + (0.05 * i);
      final period =
          Random().nextInt((widget.toPeriod - widget.fromPeriod).toInt()) +
              widget.fromPeriod;
      final phase = Random().nextDouble() * 2 * pi;
      waves.add(
        Wave(
          amplitude: amplitude,
          period: period,
          phase: phase,
        ),
      );
    }
    return waves;
  }

  @override
  void initState() {
    super.initState();
    // Generate waves for each ring
    for (var i = 0; i < widget.rings; i++) {
      waves.add(_buildWaves());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      key: const Key('avatar_rings_stack'),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return ClipPath(
              child: AnimatedRings(
                size: constraints.biggest,
                rings: widget.rings,
                radius: widget.radius,
                ringsColor: widget.ringsColor,
                ringsColorOpacity: widget.ringsColorOpacity,
                fromPeriod: widget.fromPeriod,
                toPeriod: widget.toPeriod,
                waves: waves,
              ),
            );
          },
          key: const Key('avatar_rings_rings'),
        ),
      ],
    );
  }
}
