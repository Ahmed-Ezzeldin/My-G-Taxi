//
//
//
import 'package:g_taxi/models/user_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final String mapAPIKey = 'AIzaSyC-TWIeQllYDT8l11GObNtg7r7bndZ-zEc';
UserModel currentUserInfo;
String formattedLocation;

CameraPosition cameraPosition = CameraPosition(target: LatLng(30.0444, 31.2357), tilt: 10, zoom: 10);
