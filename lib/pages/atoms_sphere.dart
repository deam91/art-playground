import 'dart:math';

import 'package:art/common/colors.dart';
import 'package:art/common/constants.dart';
import 'package:art/common/camera/matrix.dart';
import 'package:art/common/particles/particle_tail.dart';
import 'package:fast_noise/fast_noise.dart';
import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class AtomsSphere extends StatefulWidget {
  const AtomsSphere({super.key});

  @override
  State<AtomsSphere> createState() => _MainAppState();
}

class _MainAppState extends State<AtomsSphere> {
  final particles = <ParticleTail>[];
  var inc = 2.0;
  var cols = 0;
  var rows = 0;
  var zoff = .0;

  late final PerlinNoise perlinNoise;

  var flowfield = <vm.Vector3>[];
  double r = 0;
  vm.Vector3 center = vm.Vector3.zero();
  double angle = 0;
  int total = 6;

  @override
  void initState() {
    super.initState();
    perlinNoise = PerlinNoise(
      seed: total * total,
      octaves: 8,
      frequency: .1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return Processing(
          sketch: Sketch.simple(
            setup: (sketch) {
              sketch.size(width: width.toInt(), height: height.toInt());
              r = 2;
              angle = 0;
              particles.clear();
              for (var i = 0; i < total * total; i++) {
                particles.add(ParticleTail());
              }
              flowfield =
                  List.filled(1 + total + total * total, vm.Vector3.zero());
              sketch.background(color: backgroundEndColor);
            },
            draw: (sketch) async {
              // ----- Sphere
              sketch.pushMatrix();
              sketch.background(color: backgroundEndColor);

              sketch.translate(x: width / 2, y: height / 2);
              var xoff = 0.0;
              for (var i = 0; i < total; i++) {
                var yoff = 0.0;
                final lon = sketch.map(i, 0, total, -sketch.PI, sketch.PI);
                for (var j = 0; j < total; j++) {
                  final lat =
                      sketch.map(j, 0, total, -sketch.HALF_PI, sketch.HALF_PI);
                  final val = perlinNoise.getPerlin3(
                      xoff.toDouble(), yoff.toDouble(), zoff.toDouble());
                  final noiseValue = (val + 1.0) / 2.0;

                  final angleLon = lon.toDouble() * noiseValue * 4;
                  final angleLat = lat.toDouble() * noiseValue * 4;
                  final vector = vm.Vector3.zero()
                      .fromAngle(angleLon.toDouble(), angleLat.toDouble());

                  var rotated = matmul(rotationX(angle), vector);
                  // rotated = matmul(rotationZ(angle), rotated);
                  rotated = matmul(rotationY(angle), rotated);
                  const distance = 1;
                  final pz = 1.0 - (distance - rotated.z);
                  List<List<double>> projection = [
                    [1, 0, 0],
                    [0, 1, 0]
                  ];

                  final radius =
                      min(sketch.height.toDouble(), sketch.width.toDouble());
                  var projectedVector = matmul(projection, rotated);
                  (projectedVector as vm.Vector3).mult(radius / 2.1);

                  xoff += inc;
                  final index = i + j * total;
                  final value =
                      sketch.map(i + j * total, 0, i + total * total, 0, 1);
                  final color =
                      Color.lerp(Colors.blue, Colors.green, value.toDouble())!;
                  particles[index].setColor(color);
                  particles[index].setVector(projectedVector);

                  /// just the sphere points
                  // final x = (r * sin(lon) * cos(lat)) + center.x;
                  // final y = (r * sin(lon) * sin(lat)) + center.y;
                  // final z = (r * cos(lon)) + center.z;
                  // final pos = vm.Vector3(x, y, z);
                  //
                }
                yoff += inc;
              }
              angle += sketch.radians(2);
              zoff += 0.001;

              for (var particle in particles) {
                particle.show(sketch);
              }
              // sketch.noLoop();
            },
          ),
        );
      },
    );
  }
}
