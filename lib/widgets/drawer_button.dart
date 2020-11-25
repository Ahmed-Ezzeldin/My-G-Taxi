import 'package:flutter/material.dart';

class DrawerButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  DrawerButton({@required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
              icon: Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState.openDrawer();
              })),
    );
  }
}
