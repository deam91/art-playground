import 'package:art/common/colors.dart';
import 'package:art/common/constants.dart';
import 'package:art/common/particles/particle.dart';
import 'package:fast_noise/fast_noise.dart';
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
  var inc = .5;
  var cols = 0;
  var rows = 0;
  var zoff = .0;

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const scale = 20;
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return Processing(
          sketch: Sketch.simple(
            setup: (sketch) {
              sketch.size(width: width.toInt(), height: height.toInt());
              print('scale: $scale');
              cols = (sketch.width / scale).floor();
              print('width: $width, rows: $rows');
              rows = (sketch.height / scale).floor();
              print('height: $height, cols: $cols');
              particles.clear();
              for (var i = 0; i < total; i++) {
                particles.add(
                    Particle(index: i / total, width: width, height: height));
              }
              flowfield =
                  List.filled((width * height).toInt() + 1, vm.Vector2.zero());
              print('flowfield length: ${flowfield.length}');
              sketch.background(color: backgroundEndColor);
            },
            draw: (sketch) async {
              // sketch.background(color: backgroundEndColor);
              var yoff = 0.0;
              for (var y = 0; y < rows; y++) {
                var xoff = 0.0;
                for (var x = 0; x < cols; x++) {
                  final index = x + y * cols;
                  final val = perlinNoise!.getPerlin3(
                      xoff.toDouble(), yoff.toDouble(), zoff.toDouble());
                  final noiseValue = (val + 1.0) / 2.0;
                  final angle = noiseValue * TWO_PI * 4;
                  final vector = vm.Vector2.zero().fromAngle(angle);
                  vector.length = .1;
                  flowfield[index.toInt()] = vector;
                  xoff += inc;
                  // sketch.pushMatrix();
                  // // sketch.noFill();
                  // sketch.translate(x: x * scale, y: y * scale);
                  // sketch.rotate(vector.heading());
                  // sketch.stroke(color: Colors.white.withOpacity(.2));
                  // sketch.strokeWeight(1);
                  // sketch.line(const Offset(0, 0), Offset(scale.toDouble(), 0));
                  // sketch.popMatrix();
                }
                yoff += inc;
                zoff += 0.01;
              }
              // sketch.noLoop();

              for (var i = 0; i < particles.length; i++) {
                particles[i].follow(flowfield, cols);
                particles[i].update();
                particles[i].edges();
                particles[i].show(sketch);
              }
            },
          ),
        );
      },
    );
  }
}
