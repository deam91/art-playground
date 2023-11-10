import 'package:art/constants.dart';

int getIX(int x, int y) {
  return x + y * N;
}

void linSolve(int b, List<double> x, List<double> x0, double a, double c) {
  double cRecip = 1.0 / c;
  for (int k = 0; k < iter; k++) {
    for (int j = 1; j < N - 1; j++) {
      for (int i = 1; i < N - 1; i++) {
        x[getIX(i, j)] = (x0[getIX(i, j)] +
                a *
                    (x[getIX(i + 1, j)] +
                        x[getIX(i - 1, j)] +
                        x[getIX(i, j + 1)] +
                        x[getIX(i, j - 1)])) *
            cRecip;
      }
    }
    setBnd(b, x);
  }
}

class Fluid {
  final double dt;
  final double diffusion;
  final double viscosity;
  //
  int size = N;
  List<double> s = List<double>.filled(N * N, 0);
  List<double> density = List<double>.filled(N * N, 0);
  //
  List<double> vx = List<double>.filled(N * N, 0);
  List<double> vy = List<double>.filled(N * N, 0);
  //
  List<double> vx0 = List<double>.filled(N * N, 0);
  List<double> vy0 = List<double>.filled(N * N, 0);
  //
  Fluid({
    this.dt = 0,
    this.diffusion = 0,
    this.viscosity = 0,
  });

  void step() {
    diffuse(1, vx0, vx, viscosity, dt);
    diffuse(2, vy0, vy, viscosity, dt);

    project(vx0, vy0, vx, vy);

    advect(1, vx, vx0, vx0, vy0, dt);
    advect(2, vy, vy0, vx0, vy0, dt);

    project(vx, vy, vx0, vy0);

    diffuse(0, s, density, diffusion, dt);
    advect(0, density, s, vx, vy, dt);
  }

  addDensity(int x, int y, double amount) {
    density[getIX(x, y)] += amount;
  }

  addVelocity(int x, int y, double amountX, double amountY) {
    int index = getIX(x, y);
    vx[index] += amountX;
    vy[index] += amountY;
  }
}

void diffuse(int b, List<double> x, List<double> x0, double diff, double dt) {
  double a = dt * diff * (N - 2) * (N - 2);
  linSolve(b, x, x0, a, 1 + 6 * a);
}

void project(List<double> velocX, List<double> velocY, List<double> p,
    List<double> div) {
  for (int j = 1; j < N - 1; j++) {
    for (int i = 1; i < N - 1; i++) {
      div[getIX(i, j)] = -0.5 *
          (velocX[getIX(i + 1, j)] -
              velocX[getIX(i - 1, j)] +
              velocY[getIX(i, j + 1)] -
              velocY[getIX(i, j - 1)]) /
          N;
      p[getIX(i, j)] = 0;
    }
  }
  setBnd(0, div);
  setBnd(0, p);
  linSolve(0, p, div, 1, 6);

  for (int j = 1; j < N - 1; j++) {
    for (int i = 1; i < N - 1; i++) {
      velocX[getIX(i, j)] -=
          0.5 * (p[getIX(i + 1, j)] - p[getIX(i - 1, j)]) * N;
      velocY[getIX(i, j)] -=
          0.5 * (p[getIX(i, j + 1)] - p[getIX(i, j - 1)]) * N;
    }
  }
  setBnd(1, velocX);
  setBnd(2, velocY);
}

void advect(int b, List<double> d, List<double> d0, List<double> velocX,
    List<double> velocY, double dt) {
  double i0, i1, j0, j1;

  double dtx = dt * (N - 2);
  double dty = dt * (N - 2);

  double s0, s1, t0, t1;
  double tmp1, tmp2, x, y;

  int i, j;

  for (j = 1; j < N - 1; j++) {
    for (i = 1; i < N - 1; i++) {
      tmp1 = dtx * velocX[getIX(i, j)];
      tmp2 = dty * velocY[getIX(i, j)];
      x = i.toDouble() - tmp1;
      y = j.toDouble() - tmp2;

      if (x < 0.5) x = 0.5;
      if (x > N + 0.5) x = N + 0.5;
      i0 = x.floorToDouble();
      i1 = i0 + 1.0;
      if (y < 0.5) y = 0.5;
      if (y > N + 0.5) y = N + 0.5;
      j0 = y.floorToDouble();
      j1 = j0 + 1.0;

      s1 = x - i0;
      s0 = 1.0 - s1;
      t1 = y - j0;
      t0 = 1.0 - t1;

      int i0i = i0.toInt();
      int i1i = i1.toInt();
      int j0i = j0.toInt();
      int j1i = j1.toInt();

      d[getIX(i, j)] =
          s0 * (t0 * d0[getIX(i0i, j0i)] + t1 * d0[getIX(i0i, j1i)]) +
              s1 * (t0 * d0[getIX(i1i, j0i)] + t1 * d0[getIX(i1i, j1i)]);
    }
  }
  setBnd(b, d);
}

void setBnd(int b, List<double> x) {
  for (int i = 1; i < N - 1; i++) {
    x[getIX(i, 0)] = b == 2 ? -x[getIX(i, 1)] : x[getIX(i, 1)];
    x[getIX(i, N - 1)] = b == 2 ? -x[getIX(i, N - 2)] : x[getIX(i, N - 2)];
  }
  for (int j = 1; j < N - 1; j++) {
    x[getIX(0, j)] = b == 1 ? -x[getIX(1, j)] : x[getIX(1, j)];
    x[getIX(N - 1, j)] = b == 1 ? -x[getIX(N - 2, j)] : x[getIX(N - 2, j)];
  }

  x[getIX(0, 0)] = 0.5 * (x[getIX(1, 0)] + x[getIX(0, 1)]);
  x[getIX(0, N - 1)] = 0.5 * (x[getIX(1, N - 1)] + x[getIX(0, N - 2)]);
  x[getIX(N - 1, 0)] = 0.5 * (x[getIX(N - 2, 0)] + x[getIX(N - 1, 1)]);
  x[getIX(N - 1, N - 1)] =
      0.5 * (x[getIX(N - 2, N - 1)] + x[getIX(N - 1, N - 2)]);
}
