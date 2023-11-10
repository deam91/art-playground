import 'dart:math';

import 'package:vector_math/vector_math_64.dart';

// const int scale = 3;
const int N = 100;
const int iter = 4;

const TWO_PI = pi * 2;
const dimension = 600;
const scale = 10;

const chars = 'Ñ@#W\$9876543210?!abc;:+=-,._ ';

extension VectorFromAngle on Vector2 {
  Vector2 fromAngle(double angle, {double length = 1}) {
    return Vector2(length * cos(angle), length * sin(angle));
  }

  Vector2 random2D() {
    return fromAngle(Random().nextDouble() * TWO_PI);
  }

  double heading() {
    return atan2(y, x);
  }

  double magSq() {
    return x * x + y * y;
  }

  Vector2 div(double value) {
    x /= value;
    y /= value;
    return this;
  }

  Vector2 mult(double value) {
    x *= value;
    y *= value;
    return this;
  }

  limit(double max) {
    final mSq = magSq();
    if (mSq > max * max) {
      div(sqrt(mSq));
      mult(max);
    }
  }
}

extension Vector3FromAngle on Vector3 {
  double heading() {
    return atan2(y, x);
  }

  Vector3 fromAngle(double theta, double phi, {double length = 1}) {
    final cosPhi = cos(phi);
    final sinPhi = sin(phi);
    final cosTheta = cos(theta);
    final sinTheta = sin(theta);

    return Vector3(length * sinTheta * sinPhi, -length * cosTheta,
        length * sinTheta * cosPhi);
  }

  Vector3 fromSphere(double lon, double lat, {double r = 1}) {
    final sx = (r * sin(lon) * cos(lat));
    final sy = (r * sin(lon) * sin(lat));
    final sz = (r * cos(lon));

    return Vector3(sx, sy, sz);
  }

  limit(double max) {
    final mSq = magSq();
    if (mSq > max * max) {
      div(sqrt(mSq));
      mult(max);
    }
  }

  Vector3 mult(double value) {
    x *= value;
    y *= value;
    z *= value;
    return this;
  }

  Vector3 div(double value) {
    x /= value;
    y /= value;
    z /= value;
    return this;
  }

  double magSq() {
    return x * x + y * y + z * z;
  }
}
