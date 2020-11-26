import 'dart:async';

import 'package:flutter/material.dart';
import 'package:g_taxi/global_variables.dart';
import 'package:g_taxi/style/my_colors.dart';
import 'package:g_taxi/widgets/availability_button.dart';
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
  void getCurrentPosition() async {
    currentPosition =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);

    LatLng positionLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: positionLatLng, zoom: 14),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(top: 130),
            initialCameraPosition: cameraPosition,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              getCurrentPosition();
            },
          ),
          Container(
            height: 130,
            width: double.infinity,
            color: MyColors.darckBlue,
            child: Align(
              child: AvailabilityButton(
                title: 'Go online',
                color: Colors.orange,
                function: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
