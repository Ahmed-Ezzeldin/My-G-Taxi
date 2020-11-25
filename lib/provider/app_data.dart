import 'package:flutter/cupertino.dart';
import 'package:g_taxi/models/address.dart';

class AppData extends ChangeNotifier {
  Address pickupAddress;
  Address destinationAddress;

  void setPickupAddress(Address pickup) {
    pickupAddress = pickup;
    notifyListeners();
  }

  void setDestinationAddress(Address destination) {
    destinationAddress = destination;
    notifyListeners();
  }
}
