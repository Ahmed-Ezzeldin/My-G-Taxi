import 'package:flutter/material.dart';
import 'package:g_taxi/style/my_colors.dart';

class SignButton extends StatelessWidget {
  final String title;
  final Function function;

  SignButton({@required this.title, @required this.function});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: RaisedButton(
        color: MyColors.green,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Brand-Bold',
          ),
        ),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onPressed: function,
      ),
    );
  }
}
