import 'dart:math';

import 'package:art/common/colors.dart';
import 'package:art/common/camera/matrix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class SuperShapeContainer extends StatefulWidget {
  const SuperShapeContainer({super.key});

  @override
  State<SuperShapeContainer> createState() => _SuperShapeContainerState();
}

class _SuperShapeContainerState extends State<SuperShapeContainer> {
  final ValueNotifier<double> zoomNotifier = ValueNotifier(1);
  final ValueNotifier<double> m1StepNotifier = ValueNotifier(0.1);
  final ValueNotifier<Color> colorNotifier = ValueNotifier(Colors.white);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      RotatedBox(
                        quarterTurns: -1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              const Text('-'),
                              Expanded(
                                child: Slider(
                                  min: 0,
                                  max: 2,
                                  divisions: 200,
                                  label: (zoomNotifier.value * 100)
                                      .toInt()
                                      .toString(),
                                  value: zoomNotifier.value,
                                  onChanged: (value) {
                                    setState(() {
                                      zoomNotifier.value = value;
                                    });
                                  },
                                ),
                              ),
                              const Text('+'),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: SuperShape(
                            zoomNotifier: zoomNotifier,
                            m1Notifier: m1StepNotifier,
                            colorNotifier: colorNotifier,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      const Text('Velocity'),
                      Expanded(
                        child: Slider(
                          min: 0,
                          max: 1,
                          divisions: 100,
                          label: m1StepNotifier.value.toStringAsFixed(1),
                          value: m1StepNotifier.value,
                          onChanged: (value) {
                            setState(() {
                              m1StepNotifier.value = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: showPicker,
                      customBorder: RoundedRectangleBorder(
                        side: BorderSide(color: colorNotifier.value, width: 1),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Text('Color'),
                            const SizedBox(width: 10),
                            ValueListenableBuilder(
                              valueListenable: colorNotifier,
                              builder: (context, value, child) {
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: colorNotifier.value,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const SizedBox.square(dimension: 30),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  showPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          contentPadding: const EdgeInsets.all(0),
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: MaterialPicker(
              pickerColor: colorNotifier.value,
              onColorChanged: (color) {
                colorNotifier.value = color;
                Navigator.of(context).pop();
              },
              enableLabel: false,
              portraitOnly: true,
            ),
          ),
        );
      },
    );
  }
}

class SuperShape extends StatefulWidget {
  const SuperShape({
    super.key,
    this.zoomNotifier,
    this.m1Notifier,
    this.colorNotifier,
  });
  final ValueNotifier<double>? zoomNotifier;
  final ValueNotifier<double>? m1Notifier;
  final ValueNotifier<Color>? colorNotifier;

  @override
  State<SuperShape> createState() => _SuperShapeState();
}

class _SuperShapeState extends State<SuperShape> {
  List<List<vm.Vector3>> particles = <List<vm.Vector3>>[];
  double r = 200;
  double angle = 0;
  int total = 50;
  double offset = 0;
  double m1Off = 1;
  double m1Step = 0.01;
  double m2Off = 0;
  double scale = 1;
  Color color = Colors.white;

  zoom() {
    scale = widget.zoomNotifier?.value ?? 1;
  }

  updateM1() {
    m1Step = widget.m1Notifier?.value ?? 3;
  }

  updateColor() {
    color = widget.colorNotifier?.value ?? Colors.white;
  }

  @override
  void initState() {
    super.initState();
    widget.zoomNotifier?.addListener(zoom);
    widget.m1Notifier?.addListener(updateM1);
    widget.colorNotifier?.addListener(updateColor);
  }

  @override
  void dispose() {
    widget.zoomNotifier?.removeListener(zoom);
    widget.m1Notifier?.removeListener(updateM1);
    widget.colorNotifier?.removeListener(updateColor);
    super.dispose();
  }

  double supershape(num angle, double m, double n1, double n2, double n3,
      {double a = 1, double b = 1}) {
    var t1 = ((1 / a) * cos(m * angle / 4)).abs();
    t1 = pow(t1, n2).toDouble();
    var t2 = ((1 / b) * sin(m * angle / 4)).abs();
    t2 = pow(t2, n2).toDouble();
    final t3 = t1 + t2;
    return pow(t3, -1 / n1).toDouble();
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
              particles = List.generate(total + 1,
                  (i) => List.generate(total + 1, (j) => vm.Vector3.zero()));
              sketch.size(width: width.toInt(), height: height.toInt());
              sketch.background(color: backgroundEndColor);
            },
            draw: (sketch) async {
              sketch.background(color: backgroundEndColor);
              sketch.translate(x: width / 2, y: height / 2);
              //
              for (var j = 0; j < total + 1; j++) {
                final lat =
                    sketch.map(j, 0, total, -sketch.HALF_PI, sketch.HALF_PI);
                for (var i = 0; i < total + 1; i++) {
                  final lon = sketch.map(i, 0, total, -sketch.PI, sketch.PI);
                  final r1 = supershape(lon, m1Off, 5, 1, 10, a: 1, b: 1);
                  final r2 = supershape(lat, 2, 12, 2, 10, a: 1, b: 1);
                  // supershape formula
                  final x = (r * r1 * cos(lon) * r2 * cos(lat));
                  final y = (r * r1 * sin(lon) * r2 * cos(lat));
                  final z = (r * r2 * sin(lat));
                  final pos = vm.Vector3(x, y, z);
                  particles[i][j] = pos;
                }
              }

              ///
              // angle = sketch.HALF_PI / 2;

              ///
              sketch.strokeWeight(1);
              sketch.stroke(color: color);
              for (var j = 0; j < total; j++) {
                for (var i = 0; i < total; i++) {
                  final cameraProjection = projection();
                  final v1 = particles[i][j];
                  var rotated = matmul(rotationY(angle), v1);
                  rotated = matmul(rotationZ(angle), rotated);
                  // rotated = matmul(rotationX(angle), rotated);
                  final projectedVector = matmul(cameraProjection, rotated);
                  (projectedVector as vm.Vector3).scale(scale);
                  sketch.point(x: projectedVector.x, y: projectedVector.y);
                  //
                  final v2 = particles[i][j + 1];
                  rotated = matmul(rotationY(angle), v2);
                  rotated = matmul(rotationZ(angle), rotated);
                  // rotated = matmul(rotationX(angle), rotated);
                  final projectedVector2 = matmul(cameraProjection, rotated);
                  (projectedVector2 as vm.Vector3).scale(scale);
                  sketch.point(x: projectedVector2.x, y: projectedVector2.y);
                  sketch.line(Offset(projectedVector.x, projectedVector.y),
                      Offset(projectedVector2.x, projectedVector2.y));
                  //
                  final v3 = particles[i + 1][j + 1];
                  rotated = matmul(rotationY(angle), v3);
                  rotated = matmul(rotationZ(angle), rotated);
                  // rotated = matmul(rotationX(angle), rotated);
                  final projectedVector3 = matmul(cameraProjection, rotated);
                  (projectedVector3 as vm.Vector3).scale(scale);
                  sketch.point(x: projectedVector3.x, y: projectedVector3.y);
                  sketch.line(Offset(projectedVector2.x, projectedVector2.y),
                      Offset(projectedVector3.x, projectedVector3.y));
                  //
                  // sketch.vertex(projectedVector.x, projectedVector.y);
                  // sketch.vertex(projectedVector2.x, projectedVector2.y);
                  // sketch.vertex(projectedVector3.x, projectedVector3.y);
                }
              }
              // sketch.endShape();
              angle += sketch.radians(.2);
              m1Off += m1Step;
              // m2Off += 0.1;
              // sketch.noLoop();
              // offset += 0.01;
            },
          ),
        );
      },
    );
  }
}

// THE SUN!! O.O
