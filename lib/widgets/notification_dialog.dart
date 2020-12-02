import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:g_taxi/global_variables.dart';
import 'package:g_taxi/models/trip_details.dart';
import 'package:g_taxi/screens/new_trip_screen.dart';
// import 'package:firebase_database/firebase_database.dart';

class NotificationDialog extends StatelessWidget {
  final TripDetails tripDetails;
  NotificationDialog({this.tripDetails});

  void checkAvaolability(BuildContext context) {
    DatabaseReference rideRef =
        FirebaseDatabase.instance.reference().child('Drivers/${currentUser.uid}/newTrip');
    rideRef.once().then((DataSnapshot snapshot) async {
      String thisRideId = '';
      if (snapshot != null) {
        thisRideId = snapshot.value.toString();
      } else {
        print('ride not found');
      }
      if (thisRideId == tripDetails.rideId) {
        await rideRef.set('accepted');
        Navigator.of(context).pop();
        // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => NewTripScreen(tripDetails)));
        Navigator.of(context).pushNamed(NewTripScreen.routeName, arguments: tripDetails);
      } else if (thisRideId == 'cancelled') {
        print('ride has been cancelled');
      } else if (thisRideId == 'timeout') {
        print('ride has time out');
      } else {
        print('ride not found');
        // Navigator.of(context).pushNamed(NewTripScreen.routeName, arguments: tripDetails);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/taxi.png', height: 100, width: 100),
            SizedBox(height: 15),
            Text(
              'New Trip Request',
              style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 18),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/pickicon.png', height: 20, width: 20),
                      SizedBox(width: 15),
                      Expanded(
                          child: Container(
                              child: Text('${tripDetails.pickupAddress}', style: TextStyle(fontSize: 16)))),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/desticon.png', height: 20, width: 20),
                      SizedBox(width: 15),
                      Expanded(
                          child: Container(
                              child: Text('${tripDetails.destinationName}', style: TextStyle(fontSize: 18)))),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(tripDetails.rideId),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlineButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    'Decline',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    audioPlayer.stop();
                    Navigator.of(context).pop();
                  },
                ),
                OutlineButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  color: Colors.green,
                  child: Text(
                    'Accept',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    audioPlayer.stop();
                    checkAvaolability(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
