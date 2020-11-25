import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:g_taxi/helpers/helper_methods.dart';
import 'package:g_taxi/provider/app_data.dart';
import 'package:g_taxi/screens/search_destination_screen.dart';
import 'package:g_taxi/style/my_colors.dart';
import 'package:g_taxi/widgets/build_bottom_sheet_container.dart';
import 'package:g_taxi/widgets/build_drawer.dart';
import 'package:g_taxi/widgets/drawer_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class UserMapScreen extends StatefulWidget {
  static const String routeName = 'user_map_screen';

  @override
  _UserMapScreenState createState() => _UserMapScreenState();
}

class _UserMapScreenState extends State<UserMapScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final double bottomPadding = 280;
  final User user = FirebaseAuth.instance.currentUser;

  Completer<GoogleMapController> _completer = Completer();
  GoogleMapController mapController;
  CameraPosition cameraPosition = CameraPosition(target: LatLng(30.0444, 31.2357), tilt: 10, zoom: 10);
  Position position;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polyline = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);

    var destinationDetails = await FunctionsHelper.getDirectionDetails(pickLatLng, destinationLatLng);
    print(destinationDetails.encodedPoints);
    print('${destinationDetails.distanceValue}');

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(destinationDetails.encodedPoints);
    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng points) {
        polylineCoordinates.add(LatLng(points.latitude, points.longitude));
      });
    }

    _polyline.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyId'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polyline.add(polyline);
    });

    LatLngBounds bounds;
    if (pickLatLng.latitude > destinationLatLng.latitude && pickLatLng.longitude > pickLatLng.longitude) {
      bounds = LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    } else if (pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickLatLng.longitude));
    } else if (pickLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds = LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Location'),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Destination'),
    );

    Circle pickupCircle = Circle(
        circleId: CircleId('pickup'),
        strokeColor: Colors.green,
        strokeWidth: 3,
        radius: 12,
        center: pickLatLng,
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
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  void setupPositionLocator() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    LatLng pos = LatLng(position.latitude, position.longitude);
    cameraPosition = CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    await FunctionsHelper.findCordinateAddress(context, position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: BuildDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPadding),
              initialCameraPosition: cameraPosition,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              mapType: MapType.normal,
              polylines: _polyline,
              markers: _markers,
              circles: _circles,
              onMapCreated: (GoogleMapController controller) {
                _completer.complete(controller);
                mapController = controller;
                setupPositionLocator();
              },
            ),
            // ===============================================================
            // ===============================================================
            DrawerButton(scaffoldKey: _scaffoldKey),
            BuildBottomSheetContainer(
              bottomPadding,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello \"${user.email.substring(0, user.email.indexOf('@'))}\"',
                      style: TextStyle(fontSize: 12)),
                  Text(
                    'Where are you going?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Brand-Bold',
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.search, size: 28, color: MyColors.green),
                      title: Text('Search destination',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onTap: () async {
                        final result =
                            await Navigator.of(context).pushNamed(SearchDestinationScreen.routeName);
                        if (result == 'getDirection') {
                          await getDirection();
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home_outlined),
                    title: Text('Home'),
                    subtitle: Text('6th of October city - Giza Governate'),
                  ),
                  ListTile(
                    leading: Icon(Icons.work_outline),
                    title: Text('Home'),
                    subtitle: Text('6th of October city - Giza Governate'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
