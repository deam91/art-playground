import 'package:vector_math/vector_math_64.dart';

vecToMatrix(Vector3 v) {
  final m = [[], [], []];
  m[0].add(v.x);
  m[1].add(v.y);
  m[2].add(v.z);
  return m;
}

Vector3 matrixToVec(m) {
  return Vector3(m[0][0], m[1][0], m.length > 2 ? m[2][0] : 0);
}

logMatrix(List<List<int>> m) {
  final cols = m.first.length;
  final rows = m.length;
  print('$rows x $cols');
  print("----------------");
  var s = '';
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      s += '${m[i][j]} ';
    }
    print(s);
  }
}

Vector3 matmulvec(List<List<double>> a, Vector3 vec) {
  final m = vecToMatrix(vec);
  final r = matmul(a, m);
  return matrixToVec(r);
}

dynamic matmul(List<List<double>> a, dynamic b) {
  if (b is Vector3) {
    return matmulvec(a, b);
  }

  b = b as List<List<dynamic>>;
  final colsA = a.first.length;
  final rowsA = a.length;
  final colsB = b.first.length;
  final rowsB = b.length;

  if (colsA != rowsB) {
    print("Columns of A must match rows of B");
    return null;
  }

  final result = List<List<double>>.generate(
      rowsA, (index) => List.generate(colsA, (index) => 0.0));
  for (int j = 0; j < rowsA; j++) {
    result[j].add(0.0);
    for (int i = 0; i < colsB; i++) {
      var sum = 0.0;
      for (int n = 0; n < colsA; n++) {
        sum += (a[j][n]).toDouble() * (b[n][i]).toDouble();
      }
      result[j][i] = sum;
    }
  }
  return result;
}
