import 'package:flutter/material.dart';

class RiderButton extends StatelessWidget {
  final Color color;
  final Function function;
  RiderButton({@required this.color, @required this.function});
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: InkWell(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        bottomLeft: Radius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(13),
            bottomLeft: Radius.circular(13),
          ),
        ),
        child: Center(child: Text('Rider')),
      ),
      onTap: function,
    ));
  }
}
