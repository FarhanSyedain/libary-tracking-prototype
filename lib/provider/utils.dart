import 'dart:math';
//?I seriously don't understand any of this.
//?It is just for adjusting location

double dist(double x1, double y1, double x2, double y2, double x3, double y3) {
  final double px = x2 - x1;
  final double py = y2 - y1;

  final double norm = px * px + py * py;

  double u = ((x3 - x1) * px + (y3 - y1) * py) / norm;

  u = u < 0
      ? 0
      : u > 1
          ? 1
          : u;

  final x = x1 + u * px;
  final y = y1 + u * py;

  final dx = x - x3;
  final dy = y - y3;

  final dist = pow((dx * dx + dy * dy), .5);

  return double.parse(dist.toString());
}

int findPolyline(List<double> coord, List polylines) {
  double minDist = double.infinity;
  int min_idx = -1;
  for (var i = 0; i < polylines.length - 1; i += 1) {
    List<double> line1 = polylines[i];
    List<double> line2 = polylines[i + 1];
    double d = dist(line1[0], line1[1], line2[0], line2[1], coord[0], coord[1]);
    if (d < minDist) {
      minDist = d;
      min_idx = i;
    }
  }
  return min_idx;
}

double dot(List<double> vec1, List<double> vec2) {
  double sum = 0;
  for (var i = 0; i < vec1.length; i += 1) {
    sum += (vec1[i] * vec2[i]);
  }

  return sum;
}

List<double> adjustLocationSingleLine(
  List<double> driverPos,
  List<List<double>> currentLine,
) {
  List<double> driver_vec = [
    driverPos[0] - currentLine[0][0],
    driverPos[1] - currentLine[0][1]
  ];
  List<double> lineVec = [
    currentLine[1][0] - currentLine[0][0],
    currentLine[1][1] - currentLine[0][1]
  ];

  final absolutevalue = pow(dot(lineVec, lineVec), .5);
  List<double> lineUnitVec = [
    lineVec[0] / absolutevalue,
    lineVec[1] / absolutevalue
  ];
  double multiplicand = dot(driver_vec, lineUnitVec);
  List<double> new_driver_loc = [
    (multiplicand * lineUnitVec[0]) + currentLine[0][0],
    (multiplicand * lineUnitVec[1]) + currentLine[0][1]
  ];
  return new_driver_loc;
}

List<dynamic> adjustLocation(
    List<double> coords, List<List<double>> polylines) {
  int min_idx = findPolyline(coords, polylines);
  final currentLine = [polylines[min_idx], polylines[min_idx + 1]];
  List<double> adjustedLocation = adjustLocationSingleLine(coords, currentLine);

  return [min_idx, adjustedLocation];
}
