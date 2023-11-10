import 'package:art/constants.dart';
import 'package:art/particles/particle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class PerlinField extends StatefulWidget {
  const PerlinField({super.key});

  @override
  State<PerlinField> createState() => _PerlinFieldState();
}

class _PerlinFieldState extends State<PerlinField> {
  final particles = <Particle>[];
  var inc = 2.0;
  var cols = 0;
  var rows = 0;
  var zoff = .0;

  var flowfield = <vm.Vector2>[];
  int total = 500;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              return Processing(
                sketch: Sketch.simple(
                  setup: (sketch) {
                    sketch.size(width: width.toInt(), height: height.toInt());
                    particles.clear();
                    rows = (sketch.width / scale).floor();
                    cols = (sketch.height / scale).floor();
                    for (var i = 0; i < total; i++) {
                      particles.add(Particle(
                          index: i / total, width: width, height: height));
                    }
                    flowfield = List.filled(
                        1 + cols + rows * cols + 1, vm.Vector2.zero());
                    print(flowfield.length);
                    sketch.background(color: Colors.white);
                  },
                  draw: (sketch) async {
                    var yoff = 0.0;
                    for (var y = 0; y < rows; y++) {
                      var xoff = 0.0;
                      for (var x = 0; x < cols; x++) {
                        final index = x + y * cols;
                        sketch.noiseDetail(octaves: 8, falloff: .1);
                        sketch.noiseSeed((total * total).toInt());
                        final noiseValue =
                            sketch.noise(x: xoff, y: yoff, z: zoff);
                        final angle = noiseValue * TWO_PI * 4;
                        final vector = vm.Vector2.zero().fromAngle(angle);
                        vector.length = 1;
                        flowfield[index] = vector;
                        xoff += inc;
                      }
                      yoff += inc;
                      zoff += 0.01;
                    }

                    for (var i = 0; i < particles.length; i++) {
                      particles[i].follow(flowfield, cols);
                      particles[i].update();
                      particles[i].edges();
                      particles[i].show(sketch);
                    }
                    // sketch.noLoop();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
