import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:g_taxi/global_variables.dart';
import 'package:g_taxi/helpers/geofire_helper.dart';
import 'package:g_taxi/helpers/helper_methods.dart';
import 'package:g_taxi/models/direction_details.dart';
import 'package:g_taxi/models/nearby_driver.dart';
import 'package:g_taxi/provider/app_data.dart';
import 'package:g_taxi/screens/search_destination_screen.dart';
import 'package:g_taxi/style/my_colors.dart';
import 'package:g_taxi/widgets/build_bottom_sheet_container.dart';
import 'package:g_taxi/widgets/build_drawer.dart';
import 'package:g_taxi/widgets/sign_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class RiderScreen extends StatefulWidget {
  static const String routeName = 'user_map_screen';

  @override
  _RiderScreenState createState() => _RiderScreenState();
}

class _RiderScreenState extends State<RiderScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final double bottomPadding = 280;
  double searchPanelHeight = 280;
  double detailPanelHeight = 0;
  double requestPanelHeight = 0;
  bool isHasData = false;
  DirectionDetails directionDetails;
  String destinationPlace = '';
  DatabaseReference rideRequestRef;
  DatabaseReference nearDriverRef;
  BitmapDescriptor nearbyIcon;

  Completer<GoogleMapController> _completer = Completer();
  GoogleMapController mapController;

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
    setState(() {
      directionDetails = destinationDetails;
    });
    print(destinationDetails.encodedPoints);

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
        // color: Color.fromARGB(255, 95, 109, 237),
        color: Colors.blue,
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
    // Marker pickupMarker = Marker(
    //   markerId: MarkerId('pickup'),
    //   position: pickLatLng,
    //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    //   infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Location'),
    // );
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
      // _markers.add(pickupMarker);
      _markers.add(destinationMarker);
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
      destinationPlace = destination.placeName;
      isHasData = true;
    });
  }

  void showDetailsSheet() async {
    await getDirection();
    setState(() {
      searchPanelHeight = 0;
      detailPanelHeight = 280;
    });
  }

  void showRequestingSheet() {
    setState(() {
      searchPanelHeight = 0;
      detailPanelHeight = 0;
      requestPanelHeight = 280;
      isHasData = false;
    });
    createRideRequest();
  }

  void resetFun() {
    setState(() {
      polylineCoordinates.clear();
      _markers.clear();
      _circles.clear();
      searchPanelHeight = 280;
      detailPanelHeight = 0;
      requestPanelHeight = 0;
      isHasData = false;
    });
    setupPositionLocator();
  }

  void setupPositionLocator() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    LatLng pos = LatLng(position.latitude, position.longitude);
    cameraPosition = CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    await FunctionsHelper.findCordinateAddress(context, position);
    // startGeofireListener();
    getNearbyDriver();
  }

  void createRideRequest() async {
    rideRequestRef = FirebaseDatabase.instance.reference().child('RideRequests/${currentUser.uid}');
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context, listen: false).destinationAddress;
    await rideRequestRef.set({
      'created_at': DateTime.now().toString(),
      'rider_name': currentUserInfo.name,
      'rider_phone': currentUserInfo.phone,
      'pickup_address': pickup.formattedAddress,
      'destination_address': destination.formattedAddress,
      'destination_name': destination.placeName,
      'location': {'latitude': pickup.latitude, 'longitude': pickup.longitude},
      'destination': {'latitude': destination.latitude, 'longitude': destination.longitude},
      'payment_method': 'card',
      'driver_id': 'waiting',
    });
  }

  void cancelRequest() {
    rideRequestRef.remove();
  }

  void getNearbyDriver() async {
    nearDriverRef = FirebaseDatabase.instance.reference().child('AvilableDrivers');
    nearDriverRef.onValue.listen((event) {
      Map map = event.snapshot.value;
      map.forEach((key, value) {
        double latDiff = (value['latitude'] - position.latitude).abs();
        double lonDiff = (value['longitude'] - position.longitude).abs();
        //  add only the drivers in range 5 km  ***(0.01 is represent abroxamtly 1 km)
        if (latDiff < 0.05 && lonDiff < 0.05) {
          GeofireHelper.nearbyDriverList.add(NearbyDrier(
            key: key,
            latitude: value['latitude'],
            longitude: value['longitude'],
          ));
        }
      });
      print('========================');
      print(GeofireHelper.nearbyDriverList.length);
      updateDriversOnMap();
    });
  }

  void updateDriversOnMap() {
    setState(() {
      _markers.clear();
    });
    Set<Marker> tempMarker = Set<Marker>();

    for (NearbyDrier driver in GeofireHelper.nearbyDriverList) {
      LatLng driverPosition = LatLng(driver.latitude, driver.longitude);
      Marker driverMarker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverPosition,
        icon: nearbyIcon,
        rotation: FunctionsHelper.generateRandomNumber(360),
      );
      tempMarker.add(driverMarker);
    }
    setState(() {
      _markers = tempMarker;
    });
  }

  void createNearbyMarker() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: Size(2, 2),
      );
      BitmapDescriptor.fromAssetImage(
        imageConfiguration,
        'assets/images/car_android.png',
      ).then((value) => nearbyIcon = value);
    }
  }

  @override
  void initState() {
    FunctionsHelper.getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    createNearbyMarker();
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
            // =============================================================== Drawer Button
            Positioned(
              left: 5,
              top: 50,
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ],
                  ),
                  child: IconButton(
                      icon: Icon(isHasData ? Icons.arrow_back : Icons.menu),
                      onPressed: () {
                        if (isHasData) {
                          resetFun();
                        } else {
                          _scaffoldKey.currentState.openDrawer();
                        }
                      })),
            ),
            // ===============================================================
            // =============================================================== Search Panel

            BuildPanelContainer(
              searchPanelHeight,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello \"${currentUser.email.substring(0, currentUser.email.indexOf('@'))}\"',
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
                          showDetailsSheet();
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
                    subtitle: Text('Nasr city - Cairo'),
                  ),
                ],
              ),
            ),

            // ===============================================================
            // =============================================================== Details Panel

            BuildPanelContainer(
              detailPanelHeight,
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/taxi.png', height: 80, width: 80),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (directionDetails != null)
                          Text('${(directionDetails.distanceValue / 1000).toStringAsFixed(1)}  km'),
                        SizedBox(height: 10),
                        if (directionDetails != null) Text('${directionDetails.durationValue ~/ 60}  minute'),
                      ]),
                      SizedBox(),
                      SizedBox(),
                      Text(
                          directionDetails != null
                              ? '${FunctionsHelper.calculateTripCost(directionDetails)} EGP'
                              : 'No data',
                          style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold')),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset('assets/images/redmarker.png', height: 25, width: 25),
                      SizedBox(width: 20),
                      Text(destinationPlace),
                    ],
                  ),
                  Row(children: [
                    Icon(Icons.money, size: 28),
                    SizedBox(width: 10),
                    Text('Cash'),
                  ]),
                  SizedBox(height: 20),
                  SignButton(title: 'Request Taxi', function: showRequestingSheet),
                  // SignButton(
                  //     title: 'Request Taxi',
                  //     function: () {
                  //       FunctionsHelper.getCurrentUser();
                  //     }),
                ]),
              ),
            ),

            // ===============================================================
            // =============================================================== Request Panel

            BuildPanelContainer(
              requestPanelHeight,
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(height: 40, width: 40, child: CircularProgressIndicator()),
                      Text(
                        'Requsting a Ride...',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Brand-Bold'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      cancelRequest();
                      resetFun();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 1, color: MyColors.lightGrayFair)),
                      child: Icon(Icons.close, size: 25),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    child: Text(
                      'Cancel Request',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
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
