import 'dart:math';

import 'package:art/common/colors.dart';
import 'package:art/common/constants.dart';
import 'package:art/common/camera/matrix.dart';
import 'package:art/common/particles/particle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class PerlinSphere extends StatefulWidget {
  const PerlinSphere({super.key});

  @override
  State<PerlinSphere> createState() => _MainAppState();
}

class _MainAppState extends State<PerlinSphere> {
  final particles = <Particle>[];
  var inc = 2.0;
  var cols = 0;
  var rows = 0;
  var zoff = .0;

  var flowfield = <vm.Vector3>[];
  double r = 0;
  vm.Vector3 center = vm.Vector3.zero();
  double angle = 0;
  int total = 50;

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
              for (var i = 0; i < total; i++) {
                particles.add(
                    Particle(index: i / total, width: width, height: height));
              }
              flowfield =
                  List.filled(1 + total + total * total, vm.Vector3.zero());
              sketch.background(color: backgroundEndColor);
            },
            draw: (sketch) async {
              // ----- Sphere
              sketch.pushMatrix();
              // sketch.background(color: Colors.black.withOpacity(.4));
              sketch.translate(x: width / 2, y: height / 2);
              // angle = sketch.QUARTER_PI;
              var xoff = 0.0;
              for (var i = 0; i < total; i++) {
                var yoff = 0.0;
                final lon = sketch.map(i, 0, total, -sketch.PI, sketch.PI);
                for (var j = 0; j < total; j++) {
                  final lat =
                      sketch.map(j, 0, total, -sketch.HALF_PI, sketch.HALF_PI);
                  sketch.noiseDetail(octaves: 8, falloff: .1);
                  sketch.noiseSeed((total * total).toInt());
                  final noiseValue = sketch.noise(x: xoff, y: yoff, z: zoff);
                  final angleLon = lon.toDouble() * noiseValue * 4;
                  final angleLat = lat.toDouble() * noiseValue * 4;
                  final vector = vm.Vector3.zero()
                      .fromAngle(angleLon.toDouble(), angleLat.toDouble());

                  var rotated = matmul(rotationY(angle), vector);
                  rotated = matmul(rotationZ(angle), rotated);
                  // rotated = matmul(rotationX(angle), rotated);
                  const distance = .01;
                  final pz = 1.0 - (distance - rotated.z);
                  List<List<double>> projection = [
                    [1, 0, 0],
                    [0, 1, 0]
                  ];

                  var projectedVector = matmul(projection, rotated);
                  (projectedVector as vm.Vector3).mult(200);
                  // print(projectedVector.z);

                  xoff += inc;
                  final value =
                      sketch.map(i + j * total, 0, i + total * total, 0, 1);
                  sketch.stroke(
                      color: Color.lerp(Colors.blue.withOpacity(.2), Colors.red,
                              value.toDouble())!
                          .withOpacity(.3));
                  sketch.strokeWeight(5);
                  sketch.point(x: projectedVector.x, y: projectedVector.y);

                  /// just the sphere points

                  // final x = (r * sin(lon) * cos(lat)) + center.x;
                  // final y = (r * sin(lon) * sin(lat)) + center.y;
                  // final z = (r * cos(lon)) + center.z;
                  // final pos = vm.Vector3(x, y, z);
                  //
                }
                yoff += inc;
              }
              angle += sketch.radians(.5);
              zoff += 0.1;
              // sketch.noLoop();
            },
          ),
        );
      },
    );
  }
}
