import 'dart:math';

import 'package:art/common/camera/matrix.dart';
import 'package:art/common/colors.dart';
import 'package:art/common/particles/particle.dart';
import 'package:fast_noise/fast_noise.dart';
import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class Terrain extends StatefulWidget {
  const Terrain({super.key});

  @override
  State<Terrain> createState() => _TerrainState();
}

class _TerrainState extends State<Terrain> {
  final particles = <Particle>[];
  var inc = .05;
  var cols = 0;
  var rows = 0;
  var zoff = .0;
  double scl = 6;

  var flowfield = <vm.Vector2>[];
  int total = 500;
  PerlinNoise? perlinNoise;

  @override
  void initState() {
    super.initState();
    perlinNoise = PerlinNoise(
      seed: total * total,
      octaves: 8,
      frequency: .1,
    );
  }

  var angle = pi / 3;

  List<List<double>> terrain = [[]];

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
              cols = (sketch.width / scl).floor();
              rows = (sketch.height / scl).floor();
              terrain = List.generate(
                cols,
                (index) => List.generate(
                  rows,
                  (i) => sketch.random(-10, 10),
                ),
              );
              sketch.background(color: backgroundEndColor);
            },
            draw: (sketch) async {
              sketch.background(color: backgroundEndColor);
              sketch.stroke(color: Colors.white.withOpacity(.1));
              sketch.fill(color: Colors.white.withOpacity(.1));
              sketch.strokeWeight(.1);
              // sketch.noFill();
              final perspectiveMatrix = Matrix4.identity()
                ..setEntry(3, 2, -.002);
              sketch.translate(x: sketch.width / 2, y: sketch.height / 2);
              List<List<double>> projection = [
                [1, 0, 0],
                [0, 1, 0]
              ];
              var xoff = 0.0;
              for (var x = 0; x < cols - 1; x++) {
                var yoff = 0.0;
                // sketch.beginShape(ShapeMode.triangles);
                for (var y = 0; y < rows; y++) {
                  //
                  var val = perlinNoise!.getPerlin3(
                      xoff.toDouble(), yoff.toDouble(), zoff.toDouble());
                  final v1 = vm.Vector3(x * scl, y * scl, val * 20);
                  v1.applyMatrix4(Matrix4.rotationX(sketch.PI / 2.6));
                  v1.applyProjection(perspectiveMatrix);
                  // sketch.vertex(
                  //     v1.x - (sketch.width / 2), v1.y - (sketch.height / 2));
                  sketch.circle(
                    center: Offset(
                        v1.x - sketch.width / 2, v1.y - sketch.height / 2),
                    diameter: 3,
                  );
                  xoff += inc;
                  //
                  val = perlinNoise!.getPerlin3(
                      xoff.toDouble(), yoff.toDouble(), zoff.toDouble());
                  final v2 = vm.Vector3((x + 1) * scl, y * scl, val * 20);
                  v2.applyMatrix4(Matrix4.rotationX(sketch.PI / 2.6));
                  v2.applyProjection(perspectiveMatrix);
                  // sketch.vertex(
                  //     v2.x - sketch.width / 2, v2.y - sketch.height / 2);
                  sketch.circle(
                    center: Offset(
                        v2.x - sketch.width / 2, v2.y - sketch.height / 2),
                    diameter: 2,
                  );
                  xoff += inc;
                }
                // sketch.endShape();
                yoff += inc;
              }
              zoff += 0.1;
              // sketch.translate(x: -sketch.width / 2, y: -sketch.height / 2);
            },
          ),
        );
      },
    );
  }
}
