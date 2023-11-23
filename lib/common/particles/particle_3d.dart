import 'dart:math';
import 'dart:ui';

import 'package:art/common/camera/matrix.dart';
import 'package:art/common/constants.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:vector_math/vector_math_64.dart';

class Particle3 {
  Vector3 pos = Vector3.zero();
  Vector3 vel = Vector3.zero();
  Vector3 acc = Vector3.zero();
  Vector3 prevPos = Vector3.zero();
  final maxSpeed = 5.0;
  final double index;
  final double width;
  final double height;

  Particle3({required this.width, required this.height, required this.index}) {
    pos = Vector3(
        Random().nextDouble() * width, Random().nextDouble() * height, 0);
    prevPos = pos.copyInto(prevPos);
  }

  update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.multiply(Vector3.zero());
  }

  applyForce(Vector3 force) {
    acc.add(force);
  }

  show(Sketch s) {
    s.stroke(
        color: m.Color.lerp(m.Colors.red, m.Colors.blue, index.toDouble())!
            .withOpacity(.04));
    s.strokeWeight(3);
    s.line(Offset(prevPos.x, prevPos.y), Offset(pos.x, pos.y));
    updatePrev();
  }

  updatePrev() {
    prevPos.x = pos.x;
    prevPos.y = pos.y;
  }

  edges() {
    if (pos.x > width) {
      pos.x = 0;
      updatePrev();
    }
    if (pos.x < 0) {
      pos.x = width.toDouble();
      updatePrev();
    }
    if (pos.y > height) {
      pos.y = 0;
      updatePrev();
    }
    if (pos.y < 0) {
      pos.y = height.toDouble();
      updatePrev();
    }
  }

  void follow(List<Vector3> flowfield, int cols) {
    final index = pos.x.floor() + pos.y.floor() * cols;
    final force = flowfield[index];
    applyForce(force);
  }
}
