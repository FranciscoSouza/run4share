/// Google's encoded polyline format, as Strava sends routes.
/// https://developers.google.com/maps/documentation/utilities/polylinealgorithm
library;

/// (latitude, longitude) points.
List<(double, double)> decodePolyline(String encoded) {
  final points = <(double, double)>[];
  var index = 0;
  var lat = 0;
  var lng = 0;
  int next() {
    var result = 0;
    var shift = 0;
    int b;
    do {
      if (index >= encoded.length) {
        throw const FormatException('truncated polyline');
      }
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    return (result & 1) != 0 ? ~(result >> 1) : result >> 1;
  }

  try {
    while (index < encoded.length) {
      lat += next();
      lng += next();
      points.add((lat / 1e5, lng / 1e5));
    }
  } on FormatException {
    // A truncated string: keep what decoded.
  }
  return points;
}

String encodePolyline(List<(double, double)> points) {
  final out = StringBuffer();
  var lastLat = 0;
  var lastLng = 0;
  void write(int value) {
    var v = value < 0 ? ~(value << 1) : value << 1;
    while (v >= 0x20) {
      out.writeCharCode((0x20 | (v & 0x1f)) + 63);
      v >>= 5;
    }
    out.writeCharCode(v + 63);
  }

  for (final (lat, lng) in points) {
    final la = (lat * 1e5).round();
    final ln = (lng * 1e5).round();
    write(la - lastLat);
    write(ln - lastLng);
    lastLat = la;
    lastLng = ln;
  }
  return out.toString();
}
