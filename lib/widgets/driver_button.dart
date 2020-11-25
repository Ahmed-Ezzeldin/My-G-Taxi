import 'package:flutter/material.dart';

class DriverButton extends StatelessWidget {
  final Color color;
  final Function function;
  DriverButton({@required this.color, @required this.function});
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: InkWell(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(15),
        bottomRight: Radius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(13),
            bottomRight: Radius.circular(13),
          ),
        ),
        child: Center(child: Text('Driver')),
      ),
      onTap: function,
    ));
  }
}
