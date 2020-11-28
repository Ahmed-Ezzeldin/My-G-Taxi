import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:g_taxi/screens/driver_screen.dart';
import 'package:g_taxi/screens/rider_screen.dart';

class LoadingScreen extends StatelessWidget {
  static const String routeName = 'loading_screen';

  void navigatorFun(BuildContext context) async {
    User user = FirebaseAuth.instance.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users/${user.uid}');
    DataSnapshot snapshot = await userRef.once();
    // if (snapshot.value['userType'] == 'rider') {
    if (snapshot.value['userType'] == 'rider') {
      Navigator.of(context).pushReplacementNamed(UserMapScreen.routeName);
      // Navigator.of(context).pushNamedAndRemoveUntil(UserMapScreen.routeName, (route) => false);
    } else {
      Navigator.of(context).pushReplacementNamed(DriverScreen.routeName);
      // Navigator.of(context).pushNamedAndRemoveUntil(DriverScreen.routeName, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    navigatorFun(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/taxi.gif',
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            Text('Loading...', style: TextStyle(fontSize: 18))
          ],
        ),
      ),
    );
  }
}
