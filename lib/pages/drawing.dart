import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:art/common/camera/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

import 'package:art/common/colors.dart';
import 'package:art/common/particles/particle.dart';
import 'package:art/common/utils.dart';
import 'package:art/pages/atoms_sphere.dart';

class Drawing extends StatefulWidget {
  const Drawing({super.key});

  @override
  State<Drawing> createState() => _MainAppState();
}

class _MainAppState extends State<Drawing> {
  late final Future<void>? loading;

  final particles = <Particle>[];
  var time = .0;
  final radius = 50.0;
  double scale = 2;

  List<vm.Vector2> path = [];
  List<double> y = [];
  List<double> x = [];
  List<Map>? fourierY;
  List<Map>? fourierX;

  double maxWidth = 0;
  double maxHeight = 0;

  final cameraProjection = projection();

  @override
  void initState() {
    super.initState();
    loading = _loadSvg();
  }

  // TODO: Move this logic to an isolate
  Future<void> _loadSvg() async {
    // const name = 'assets/svg/supersonic-bullet.svg';
    // final paths = await loadSvgImage(svgImage: name);
    //
    // TODO: Finish ffi call passing a svg string to get paths points
    // call(generalString);
    final paths = await loadSvgJson(svg: 'assets/parser/paths.json');

    for (var i = 0; i < paths.length; i++) {
      y.add(paths[i].x);
      x.add(paths[i].y);
    }
    final size = await getSvgSize(svgImage: 'assets/deamdeveloper.svg');
    maxWidth = size.width;
    maxHeight = size.height;
    fourierY = dft(y);
    fourierX = dft(x);
    fourierX!
        .sort((a, b) => (b['amp'] as double).compareTo(a['amp'] as double));
    fourierY!
        .sort((a, b) => (b['amp'] as double).compareTo(a['amp'] as double));
    setState(() {});
    return;
  }

  List<Map>? dft(List<double> values) {
    final length = values.length;
    final x = List<Map<String, double>>.generate(length, (index) => {});
    for (var k = 0; k < length; k++) {
      var d = .0;
      var im = .0;
      for (var n = 0; n < length; n++) {
        var angle = ((pi * 2) * k * n) / length;
        d += values[n] * cos(angle);
        im -= values[n] * sin(angle);
      }
      d = d / length;
      im = im / length;
      //
      final freq = k;
      final amp = sqrt(d * d + im * im);
      final phase = atan2(im, d);
      x[k] = {
        'd': d,
        'im': im,
        'freq': freq.toDouble(),
        'amp': amp,
        'phase': phase,
      };
    }
    return x;
  }

  vm.Vector2 epiCycle(
      Sketch s, double x0, double y0, List<Map> fourier, double rotation) {
    for (var i = 0; i < fourier.length; i++) {
      double prevX = x0;
      double prevY = y0;
      //
      // var n = i * 2 + 1;
      // lon = radius * (4 / (n * pi));
      // x0 += lon * cos(n * time);
      // y0 += lon * sin(n * time);
      var n = fourier[i]['freq'];
      final lon = fourier[i]['amp'];
      x0 += lon * cos(n * time + fourier[i]['phase'] + rotation);
      y0 += lon * sin(n * time + fourier[i]['phase'] + rotation);
      //
      // s.stroke(color: Colors.white.withOpacity(.2));
      // s.circle(center: Offset(prevX, prevY), diameter: lon * 2);
      // //
      // s.strokeWeight(1);
      // s.stroke(color: Colors.white.withOpacity(.9));
      // s.line(Offset(prevX, prevY), Offset(x0, y0));
    }
    return vm.Vector2(x0, y0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loading,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: 100,
                child: AtomsSphere(),
              ),
              SizedBox(height: 20),
              Text('PROCESSING...'),
            ],
          ));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              return Processing(
                sketch: Sketch.simple(
                  setup: (sketch) {
                    sketch.size(width: width.toInt(), height: height.toInt());
                    sketch.background(color: backgroundEndColor);
                  },
                  draw: (sketch) async {
                    sketch.background(color: backgroundEndColor);
                    sketch.translate(
                      x: sketch.width / 2 - (maxWidth / 2 * scale),
                      y: sketch.height / 2 - (maxHeight / 2 * scale),
                    );
                    sketch.pushMatrix();
                    sketch.noFill();
                    sketch.stroke(color: Colors.white.withOpacity(.5));
                    sketch.strokeWeight(1);
                    //
                    final vx = epiCycle(sketch, 0, 0, fourierX!, 0);
                    final vy =
                        epiCycle(sketch, 0, 0, fourierY!, sketch.HALF_PI);
                    final vector = vm.Vector2(vx.x, vy.y);
                    path.insert(0, vector);
                    //
                    // sketch.stroke(color: Colors.white.withOpacity(.2));
                    // sketch.line(Offset(vx.x, vx.y), Offset(vector.x, vector.y));
                    // sketch.line(Offset(vy.x, vy.y), Offset(vector.x, vector.y));
                    // sketch.stroke(color: Colors.white.withOpacity(.9));
                    // sketch.beginShape();
                    for (var i = 0; i < path.length; i++) {
                      final v1 = vm.Vector3(path[i].x, path[i].y, 0);
                      var rotated = matmul(rotationX(sketch.PI), v1);
                      rotated = matmul(rotationZ(sketch.PI / 2), rotated);
                      final projectedVector = matmul(cameraProjection, rotated);
                      (projectedVector as vm.Vector3).scale(scale);
                      sketch.circle(
                        center: Offset(projectedVector.x, projectedVector.y),
                        diameter: 1,
                      );
                    }
                    // sketch.endShape();

                    sketch.popMatrix();
                    final dt = sketch.TWO_PI / fourierY!.length;
                    time += dt * 4;

                    if (path.length > sketch.width) {
                      path.removeLast();
                    }
                    // sketch.noLoop();
                  },
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
