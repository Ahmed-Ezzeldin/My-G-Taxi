import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:g_taxi/global_variables.dart';
import 'package:g_taxi/models/trip_details.dart';
import 'package:g_taxi/style/my_colors.dart';
import 'package:g_taxi/widgets/sign_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:g_taxi/helpers/helper_methods.dart';

class NewTripScreen extends StatefulWidget {
  static const String routeName = 'new_trip_screen';
  @override
  _NewTripScreenState createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController mapController;
  Completer<GoogleMapController> _completer = Completer();

  Set<Marker> _markers = Set<Marker>();
  Set<Circle> _circles = Set<Circle>();
  Set<Polyline> _polylines = Set<Polyline>();

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  Future<void> getDirection(LatLng pickupLatLng, LatLng destinationLatLng) async {
    var destinationDetails = await FunctionsHelper.getDirectionDetails(pickupLatLng, destinationLatLng);

    List<PointLatLng> results = polylinePoints.decodePolyline(destinationDetails.encodedPoints);
    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng points) {
        polylineCoordinates.add(LatLng(points.latitude, points.longitude));
      });
    }

    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyId'),
        // color: Color.fromARGB(255, 95, 109, 237),
        color: Colors.blue,
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polylines.add(polyline);
    });

    LatLngBounds bounds;
    if (pickupLatLng.latitude > destinationLatLng.latitude &&
        pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    } else if (pickupLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickupLatLng.longitude));
    } else if (pickupLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
          northeast: LatLng(pickupLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds = LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
    // Marker pickupMarker = Marker(
    //   markerId: MarkerId('pickup'),
    //   position: pickupLatLng,
    //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    // );
    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    Circle pickupCircle = Circle(
        circleId: CircleId('pickup'),
        strokeColor: Colors.green,
        strokeWidth: 3,
        radius: 12,
        center: pickupLatLng,
        fillColor: Colors.greenAccent);

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: Colors.deepPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: Colors.purple,
    );
    setState(() {
      // _markers.add(pickupMarker);
      _markers.add(destinationMarker);
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  @override
  Widget build(BuildContext context) {
    TripDetails tripDetails = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      // appBar: AppBar(title: Text('New Trip')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: cameraPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            trafficEnabled: true,
            mapType: MapType.normal,
            markers: _markers,
            circles: _circles,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) async {
              mapController = controller;
              _completer.complete(controller);
              LatLng currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
              LatLng pickupLatLng = tripDetails.destination;
              await getDirection(currentLatLng, pickupLatLng);
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 280,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '14 Mins',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Brand-Bold',
                      color: MyColors.accentPurple,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${tripDetails.riderName}',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Brand-Bold',
                        ),
                      ),
                      Icon(Icons.call),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/pickicon.png', height: 20, width: 20),
                      SizedBox(width: 15),
                      Expanded(
                          child: Container(
                        child: Text(
                          '${tripDetails.pickupAddress}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16),
                        ),
                      )),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/desticon.png', height: 20, width: 20),
                      SizedBox(width: 15),
                      Expanded(
                          child: Container(
                        child: Text(
                          '${tripDetails.destinationName}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16),
                        ),
                      )),
                    ],
                  ),
                  SignButton(title: 'Arrived', function: () {})
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
