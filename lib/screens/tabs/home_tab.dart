import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:g_taxi/global_variables.dart';
import 'package:g_taxi/helpers/push_notification_service.dart';
import 'package:g_taxi/style/my_colors.dart';
import 'package:g_taxi/widgets/confirm_sheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  Position currentPosition;
  bool isOnline = false;

  void getCurrentPosition() async {
    currentPosition =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);

    LatLng positionLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: positionLatLng, zoom: 14),
    ));
  }

  void goOnlineFun(Position position) {
    avilableDrivers = FirebaseDatabase.instance.reference().child('AvilableDrivers/${currentUser.uid}');
    avilableDrivers.set({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
    tripRequestRef = FirebaseDatabase.instance.reference().child('Drivers/${currentUser.uid}/newTrip');
    tripRequestRef.set('waiting');
    tripRequestRef.onValue.listen((event) {});
  }

  void goOfflineFun() {
    avilableDrivers.onDisconnect();
    avilableDrivers.remove();
    avilableDrivers = null;
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
    tripRequestRef = null;
  }

  void getLocationUpdate() {
    homeTabPositionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    ).listen((Position position) {
      currentPosition = position;
      if (isOnline) {
        // Geofire.setLocation(currentUser.uid, position.latitude, position.longitude);
        goOnlineFun(currentPosition);
      }
      mapController.animateCamera(CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
    });
  }

  void getCurrentDriverInfo() async {
    // currentFirebaseUser = await FirebaseAuth.instance.currentUser;
    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize();
    pushNotificationService.getToken();
  }

  @override
  void initState() {
    super.initState();
    getCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 100),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: cameraPosition,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              getCurrentPosition();
            },
          ),
          Container(
            height: 100,
            width: double.infinity,
            color: Colors.blueGrey.shade800,
            child: Align(
              child: SwitchListTile(
                value: isOnline,
                title: Text(isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: isOnline ? MyColors.green : Colors.white,
                      fontFamily: 'Brand-Bold',
                    )),
                activeColor: MyColors.green,
                onChanged: (value) async {
                  final result = await showModalBottomSheet(
                    context: context,
                    builder: (ctx) => ConfirmSheet(
                      title: !isOnline ? 'Go Online' : 'Go Offline',
                      subtitle: !isOnline
                          ? 'Are you sure about become available to receive trip requests'
                          : 'You will become unavailable and stop receiving trip requests ',
                      buttonColor: !isOnline ? MyColors.green : Colors.redAccent,
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      isOnline = !isOnline;
                    });
                    if (isOnline) {
                      goOnlineFun(currentPosition);
                      getLocationUpdate();
                    } else {
                      goOfflineFun();
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
