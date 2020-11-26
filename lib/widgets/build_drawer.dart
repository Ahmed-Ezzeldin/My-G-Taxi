import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:g_taxi/screens/auth_screen.dart';

class BuildDrawer extends StatelessWidget {
  const BuildDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: <Widget>[
          Container(
            color: Colors.white,
            height: 160,
            child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Image.asset('assets/images/user_icon.png', height: 60, width: 60),
                    SizedBox(width: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Uchenna ', style: TextStyle(fontSize: 20, fontFamily: 'Brand-Bold')),
                        SizedBox(height: 5),
                        Text('View Profile'),
                      ],
                    ),
                  ],
                )),
          ),
          Divider(),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.card_giftcard),
            title: Text('Free Rides'),
          ),
          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text('Payments'),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Ride History'),
          ),
          ListTile(
            leading: Icon(Icons.contact_support),
            title: Text('Support'),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(
              'Logout',
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
