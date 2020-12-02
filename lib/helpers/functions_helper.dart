import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:g_taxi/global_variables.dart';
import 'package:g_taxi/models/address.dart';
import 'package:g_taxi/models/direction_details.dart';
import 'package:g_taxi/models/user_model.dart';
import 'package:g_taxi/provider/app_data.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class FunctionsHelper {
// ==================================================================
// ==================================================================

  static void showMessageAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => AlertDialog(
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 10),
          Text('Error!'),
        ]),
        content: Text(message),
        actions: [
          FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ],
      ),
    );
  }

// ==================================================================
// ==================================================================

  static Future<dynamic> getRequest(String url) async {
    http.Response response = await http.get(url);
    try {
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        return decodedData;
      } else {
        return 'failed';
      }
    } catch (error) {
      print(error);
      return 'failed';
    }
  }

// ==================================================================
// ==================================================================

  static Future<String> findCordinateAddress(BuildContext context, Position position) async {
    String address = '';
    ConnectivityResult result = await Connectivity().checkConnectivity();
    if (result != ConnectivityResult.mobile && result != ConnectivityResult.wifi) {
      return address;
    }
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapAPIKey';

    final response = await getRequest(url);

    if (response != 'failed') {
      address = response['results'][0]['formatted_address'];
      Address pickupAddress = Address(
        latitude: position.latitude,
        longitude: position.longitude,
        placeName: response['results'][0]['address_components'][1]['short_name'],
        formattedAddress: address,
      );
      formattedLocation = pickupAddress.formattedAddress;
      Provider.of<AppData>(context, listen: false).setPickupAddress(pickupAddress);
    }
    return address;
  }

// ==================================================================
// ==================================================================

  static Future<DirectionDetails> getDirectionDetails(LatLng startPosition, LatLng endPosition) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude} , ${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&key=$mapAPIKey';
    final response = await getRequest(url);
    if (response == 'failed') {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails(
      distanceValue: response['routes'][0]['legs'][0]['distance']['value'],
      distanceText: response['routes'][0]['legs'][0]['distance']['text'],
      durationValue: response['routes'][0]['legs'][0]['duration']['value'],
      durationText: response['routes'][0]['legs'][0]['duration']['text'],
      encodedPoints: response['routes'][0]['overview_polyline']['points'],
    );
    return directionDetails;
  }

// ==================================================================
// ==================================================================
  static int calculateTripCost(DirectionDetails details) {
    // trip base   : EGP 5
    // every km    : $ 2
    // every minute : $ 1

    int totalCost = 5 + (details.distanceValue / 1000 * 2).toInt() + (details.durationValue / 60 * 1).toInt();
    return totalCost;
  }
// ==================================================================
// ==================================================================

  static void getCurrentUser() {
    User user = FirebaseAuth.instance.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('Riders/${user.uid}');
    userRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        print(snapshot.value);
        currentUserInfo = UserModel.fromSnapshot(snapshot);
      }
    });
  }

// ==================================================================
// ==================================================================

  static double generateRandomNumber(int max) {
    int randomInt = Random().nextInt(max);
    return randomInt.toDouble();
  }

// ==================================================================
// ==================================================================
// ==================================================================
// ==================================================================

  static void disableHomeTabLocationUpdate() {
    // homeTabPositionStream.pause();
    // avilableDrivers.remove();
  }

  static void enableHomeTabLocationUpdate() {
    homeTabPositionStream.resume();
    avilableDrivers = FirebaseDatabase.instance.reference().child('AvilableDrivers/${currentUser.uid}');
    avilableDrivers.set({
      'latitude': currentPosition.latitude,
      'longitude': currentPosition.longitude,
    });
  }
}
