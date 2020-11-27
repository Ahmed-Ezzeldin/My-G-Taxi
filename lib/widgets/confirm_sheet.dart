import 'package:flutter/material.dart';
import 'package:g_taxi/style/my_colors.dart';

class ConfirmSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color buttonColor;
  ConfirmSheet({this.title, this.subtitle, this.buttonColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MyColors.text,
                fontSize: 22,
                fontFamily: 'Brand-Bold',
              )),
          SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: MyColors.textLight),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildRaisedButton(
                context,
                '  Back  ',
                Colors.grey,
                () {
                  Navigator.of(context).pop();
                },
              ),
              buildRaisedButton(
                context,
                'Confirm',
                buttonColor,
                () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  RaisedButton buildRaisedButton(
    BuildContext context,
    String title,
    Color color,
    Function function,
  ) {
    return RaisedButton(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamily: 'Brand-Bold',
        ),
      ),
      onPressed: function,
    );
  }
}
