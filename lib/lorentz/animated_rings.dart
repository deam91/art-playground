import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_processing/flutter_processing.dart';

/// The widget used to animate and style the rings.
class AnimatedRings extends StatefulWidget {
  /// The constructor for the [AnimatedRings] class
  ///
  /// Accepts the amount of [rings], the [radius] of
  /// the entire rings painter, a [spaceBetweenRings] space between each ring,
  /// a [fromPeriod] for the start period value, a [toPeriod] for the end
  /// period value, a [ringsColor] for the color of the rings, and a
  /// [ringsColorOpacity] for the opacity for the rings.
  ///
  /// - The [radius] must be bigger than the [rings] multiplied with the
  /// [spaceBetweenRings].
  ///
  /// - The [rings] must less/equal to 16 to keep performance
  ///
  /// - The [fromPeriod] and [toPeriod] values must be between 10 and 400
  ///
  /// - The [toPeriod] must be bigger or equal to [fromPeriod]
  ///
  const AnimatedRings({
    super.key,
  });

  @override
  State<AnimatedRings> createState() => _AnimatedRingsState();
}

class _AnimatedRingsState extends State<AnimatedRings>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double a = 10;
  double b = 28;
  double c = 8 / 3;
  double x = 0.01;
  double y = 0;
  double z = 0;

  late PImage image;
  late AssetBundle _assetBundle;

  drawLorentz(Sketch s) {
    s.pushMatrix();
    s.translate(x: s.width / 2, y: s.height / 2);
    const dt = 0.01;
    final dx = (a * (y - x)) * dt;
    final dy = (x * (b - z) - y) * dt;
    final dz = (x * y - c * z) * dt;
    print('dx: $dx, dy: $dy, dz: $dz');
    x = x + dx;
    y = y + dy;
    z = z + dz;
    print('x: $x, y: $y, z: $z');
    final offset = Offset(x + s.width / 2, y + s.width / 2);
    print('offset: $offset');
    s.stroke(color: Colors.white);
    s.strokeWeight(2);
    s.fill(color: Colors.white);

    s.point(x: x, y: y);

    s.popMatrix();
  }

  @override
  Widget build(BuildContext context) {
    return Processing(
      sketch: Sketch.simple(
        setup: (s) async {
          // image = await s.loadImage('assets/image.png');
          s.background(color: Colors.black54);

          // final imageData = await rootBundle.load('assets/image.png');
          // final img = Image.asset('assets/image.png');

          // image = PImage.fromPixels(
          //   img.width?.toInt() ?? 0,
          //   img.height?.toInt() ?? 0,
          //   imageData,
          //   ImageFileFormat.png,
          // );
        },
        draw: (s) {
          s.size(width: 250, height: 250);
          // s.image(image: image);
          s.noLoop();
        },
      ),
    );
  }
}
