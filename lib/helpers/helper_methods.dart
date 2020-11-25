import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:g_taxi/global_variables.dart';
import 'package:g_taxi/models/address.dart';
import 'package:g_taxi/models/direction_details.dart';
import 'package:g_taxi/provider/app_data.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class FunctionsHelper {
  // static void showLoadingDialog(BuildContext context, String statusMessage) {
  //   showDialog(
  //     context: context,
  //     // barrierDismissible: false,
  //     builder: (BuildContext ctx) => Dialog(
  //       // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //       shape: BeveledRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Container(
  //         padding: const EdgeInsets.all(20),
  //         child: Row(
  //           children: [
  //             CircularProgressIndicator(),
  //             SizedBox(width: 20),
  //             Expanded(
  //               child: Text(
  //                 statusMessage,
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(fontSize: 18),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
        placeFormattedAddress: address,
      );
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

  // static Future<void> getDirection(BuildContext context) async {
  //   var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
  //   var destination = Provider.of<AppData>(context, listen: false).destinationAddress;

  //   var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
  //   var destinationLatLng = LatLng(destination.latitude, destination.longitude);

  //   var destinationDetails = await FunctionsHelper.getDirectionDetails(pickLatLng, destinationLatLng);
  //   print(destinationDetails.encodedPoints);

  //   PolylinePoints polylinePoints = PolylinePoints();
  //   List<PointLatLng> results = PolylinePoints().decodePolyline(destinationDetails.encodedPoints);
  //   if(results.isNotEmpty){
  //     results.forEach((PointLatLng point) {
  //       pol
  //     });
  //   }

  // }

// ==================================================================
// ==================================================================

}
