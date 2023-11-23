import 'dart:math';
import 'dart:ui';

import 'package:art/common/constants.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_processing/flutter_processing.dart';
import 'package:vector_math/vector_math_64.dart';

class Particle {
  Vector2 pos = Vector2.zero();
  Vector2 vel = Vector2.zero();
  Vector2 acc = Vector2.zero();
  Vector2 prevPos = Vector2.zero();
  final maxSpeed = 3.0;
  final double index;
  final double width;
  final double height;

  Particle({required this.width, required this.height, required this.index}) {
    pos =
        Vector2(Random().nextDouble() * width, Random().nextDouble() * height);
    prevPos = pos.copyInto(prevPos);
  }

  update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.multiply(Vector2.zero());
  }

  applyForce(Vector2 force) {
    acc.add(force);
  }

  show(Sketch s) {
    s.stroke(
        color: m.Color.lerp(m.Colors.red, m.Colors.blue, index.toDouble())!
            .withOpacity(.1));
    s.strokeWeight(1);
    s.line(Offset(prevPos.x, prevPos.y), Offset(pos.x, pos.y));
    // s.point(x: pos.x, y: pos.y);
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

  void follow(List<Vector2> flowfield, int cols) {
    final x = (pos.x / scale).floor();
    final y = (pos.y / scale).floor();
    final index = x + y * cols;
    final force = flowfield[index];
    applyForce(force);
  }
}
