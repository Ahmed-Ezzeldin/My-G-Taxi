import 'package:maps_toolkit/maps_toolkit.dart';

class MapKitHelper {
  static double getMarkerRotation(fromLat, fromLng, toLat, toLng) {
    var rotation = SphericalUtil.computeHeading(
      LatLng(fromLat, fromLng),
      LatLng(toLat, toLng),
    );
    return rotation;
  }
}
