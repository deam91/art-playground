import 'dart:ui';
import 'package:flutter_processing/flutter_processing.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/material.dart' as m;

class ParticleTail {
  List<Vector3> previousVectors = [];
  Color color = m.Colors.white;

  ParticleTail();

  setColor(m.Color color) {
    this.color = color;
  }

  setVector(Vector3 vector) {
    if (previousVectors.length > 20) {
      previousVectors.add(vector);
      previousVectors.removeAt(0);
    } else {
      previousVectors.add(vector);
    }
  }

  show(Sketch s) {
    s.stroke(color: color);
    s.fill(color: color);
    s.strokeWeight(1);
    Vector3? previous;
    for (var i = previousVectors.length - 1; i >= 0; i--) {
      final vector = previousVectors[i];
      s.circle(
        center: Offset(vector.x, vector.y),
        diameter: i.toDouble() / 10,
      );
      if (previous != null) {
        s.stroke(color: color.withOpacity(.1));
        s.line(Offset(previous.x, previous.y), Offset(vector.x, vector.y));
      }
      if (i != 0) {
        previous = vector;
      }
    }
  }
}
