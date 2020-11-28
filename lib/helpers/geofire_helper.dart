import 'package:g_taxi/models/nearby_driver.dart';

class GeofireHelper {
  static List<NearbyDrier> nearbyDriverList = [];

  static void removeFromList(String key) {
    int index = nearbyDriverList.indexWhere((element) => element.key == key);
    nearbyDriverList.removeAt(index);
    // nearbyDriverList.removeWhere((element) => element.key == key);
  }

  static void updateNearbyLocation(NearbyDrier driver) {
    int index = nearbyDriverList.indexWhere((element) => element.key == driver.key);
    nearbyDriverList[index].latitude = driver.latitude;
    nearbyDriverList[index].longitude = driver.longitude;
  }
}
