import 'package:flutter/material.dart';
import 'package:g_taxi/helpers/functions_helper.dart';
import 'package:g_taxi/widgets/sign_button.dart';

class CollectPaymentDialog extends StatelessWidget {
  final String paymentMethod;
  final int cost;
  CollectPaymentDialog(this.paymentMethod, this.cost);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Text(
              '$paymentMethod Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text(
              '\$$cost',
              style: TextStyle(fontSize: 40, fontFamily: 'Brand-Bold'),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('Amount above is the total cost of the trip.', textAlign: TextAlign.center),
            ),
            SizedBox(height: 30),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: SignButton(
                title: paymentMethod == 'cash' ? 'Collect Cash' : 'Confirm',
                function: () {
                  // Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  FunctionsHelper.enableHomeTabLocationUpdate();
                },
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
