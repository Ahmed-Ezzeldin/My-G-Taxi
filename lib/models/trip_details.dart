import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails {
  String destinationAddress;
  String destinationName;
  String pickupAddress;
  LatLng destination;
  LatLng pickup;
  String rideId;
  String riderName;
  String riderPhone;
  String paymentMethod;

  TripDetails({
    this.destinationAddress,
    this.destinationName,
    this.pickupAddress,
    this.destination,
    this.pickup,
    this.rideId,
    this.riderName,
    this.riderPhone,
    this.paymentMethod,
  });
}
