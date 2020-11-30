import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../global_variables.dart';

class PushNotificationService {
  final FirebaseMessaging fcm = FirebaseMessaging();
  Future initialize() async {
    print('==========> FCM Initialize');
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideId(message));
      },
      onLaunch: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideId(message));
      },
      onResume: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideId(message));
      },
    );
  }

  String getRideId(Map<String, dynamic> message) {
    String rideId = '';
    rideId = message['data']['ride_id'];
    return rideId;
  }

  void fetchRideInfo(String riderId) {
    DatabaseReference rideRef = FirebaseDatabase.instance.reference().child('RideRequests/$riderId');
    rideRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        String pickupAddress = snapshot.value['pickup_address'];
        // double pickupLat = snapshot.value['location']['latitude'];
        // double pickupLng = snapshot.value['location']['longitude'];
        // String destinationAddress = snapshot.value['destination_address'];
        // double destinationLat = snapshot.value['destination']['latitude'];
        // double destinationLng = snapshot.value['destination']['longitude'];
        // String paymentMethod = snapshot.value['payment_method'];
        String riderName = snapshot.value['rider_name'];
        String riderPhone = snapshot.value['rider_phone'];
        print(pickupAddress);
        print(riderName);
        print(riderPhone);
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
