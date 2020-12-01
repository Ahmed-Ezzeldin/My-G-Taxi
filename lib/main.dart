import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:g_taxi/provider/app_data.dart';
import 'package:g_taxi/screens/auth_screen.dart';
import 'package:g_taxi/screens/driver_screen.dart';
import 'package:g_taxi/screens/loading_screen.dart';
import 'package:g_taxi/screens/new_trip_screen.dart';
import 'package:g_taxi/screens/search_destination_screen.dart';
import 'package:g_taxi/screens/rider_screen.dart';
import 'package:provider/provider.dart';

import 'global_variables.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  currentUser = FirebaseAuth.instance.currentUser;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Brand-Regular',
          primarySwatch: Colors.green,
          primaryColor: Colors.greenAccent.shade700,
        ),
        // home: StreamBuilder(
        //     stream: FirebaseAuth.instance.userChanges(),
        //     builder: (ctx, snapshot) {
        //       if (snapshot.hasData) {
        //         // return UserMapScreen();
        //         return LoadingScreen();
        //       }
        //       return AuthScreen();
        //     }),
        routes: {
          "/": (ctx) => currentUser != null ? LoadingScreen() : AuthScreen(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
          RiderScreen.routeName: (ctx) => RiderScreen(),
          SearchDestinationScreen.routeName: (ctx) => SearchDestinationScreen(),
          DriverScreen.routeName: (ctx) => DriverScreen(),
          LoadingScreen.routeName: (ctx) => LoadingScreen(),
          NewTripScreen.routeName: (ctx) => NewTripScreen(),
        },
      ),
    );
  }
}
