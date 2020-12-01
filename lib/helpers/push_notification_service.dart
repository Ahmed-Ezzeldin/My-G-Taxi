import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:g_taxi/models/trip_details.dart';
import 'package:g_taxi/widgets/notification_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global_variables.dart';

class PushNotificationService {
  final FirebaseMessaging fcm = FirebaseMessaging();
  Future initialize(BuildContext context) async {
    print('==========> FCM Initialize');
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideId(message), context);
      },
      onLaunch: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideId(message), context);
      },
      onResume: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideId(message), context);
      },
    );
  }

  String getRideId(Map<String, dynamic> message) {
    String rideId = '';
    rideId = message['data']['ride_id'];
    return rideId;
  }

  void fetchRideInfo(String riderId, BuildContext context) {
    DatabaseReference rideRef = FirebaseDatabase.instance.reference().child('RideRequests/$riderId');
    rideRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        audioPlayer.open(Audio('assets/sounds/alert.mp3'));
        String pickupAddress = snapshot.value['pickup_address'];
        double pickupLat = snapshot.value['location']['latitude'];
        double pickupLng = snapshot.value['location']['longitude'];
        String destinationAddress = snapshot.value['destination_address'];
        String destinationName = snapshot.value['destination_name'];
        double destinationLat = snapshot.value['destination']['latitude'];
        double destinationLng = snapshot.value['destination']['longitude'];
        String paymentMethod = snapshot.value['payment_method'];
        String riderName = snapshot.value['rider_name'];
        String riderPhone = snapshot.value['rider_phone'];

        TripDetails tripDetails = TripDetails(
          riderId: riderId,
          riderName: riderName,
          riderPhone: riderPhone,
          pickupAddress: pickupAddress,
          destinationAddress: destinationAddress,
          destinationName: destinationName,
          pickup: LatLng(pickupLat, pickupLng),
          destination: LatLng(destinationLat, destinationLng),
          paymentMethod: paymentMethod,
        );

        print(tripDetails.destinationAddress);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => NotificationDialog(tripDetails: tripDetails),
        );
      }
    });
  }

  Future<String> getToken() async {
    String token = await fcm.getToken();
    print('Token: ==========> $token');
    DatabaseReference tokenRef =
        FirebaseDatabase.instance.reference().child('Drivers/${currentUser.uid}/fcmToken');
    tokenRef.set(token);

    fcm.subscribeToTopic('alldrivers');
    fcm.subscribeToTopic('allusers');
    return token;
  }
}
