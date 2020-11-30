import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:g_taxi/screens/driver_screen.dart';
import 'package:g_taxi/screens/rider_screen.dart';
import 'package:g_taxi/style/my_colors.dart';

import '../global_variables.dart';

class LoadingScreen extends StatelessWidget {
  static const String routeName = 'loading_screen';

  void navigatorFun(BuildContext context) async {
    try {
      currentUser = FirebaseAuth.instance.currentUser;
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('Riders/${currentUser.uid}');
      DataSnapshot snapshot = await userRef.once();
      // if (snapshot.value['userType'] == 'rider') {
      if (snapshot.value != null) {
        Navigator.of(context).pushReplacementNamed(RiderScreen.routeName);
        // Navigator.of(context).pushNamedAndRemoveUntil(UserMapScreen.routeName, (route) => false);
      } else {
        Navigator.of(context).pushReplacementNamed(DriverScreen.routeName);
        // Navigator.of(context).pushNamedAndRemoveUntil(DriverScreen.routeName, (route) => false);
      }
    } on PlatformException catch (error) {
      print('Error: ${error.message}');
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    navigatorFun(context);
    return Scaffold(
      backgroundColor: MyColors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/taxi.gif',
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            Text('Loading...', style: TextStyle(fontSize: 18, color: Colors.white))
          ],
        ),
      ),
    );
  }
}
