import 'package:flutter/material.dart';
import 'package:g_taxi/global_variables.dart';
import 'package:g_taxi/helpers/functions_helper.dart';
import 'package:g_taxi/models/address.dart';
import 'package:g_taxi/models/prediction.dart';
import 'package:g_taxi/provider/app_data.dart';
import 'package:provider/provider.dart';

class PredictionListTile extends StatelessWidget {
  final Prediction prediction;
  PredictionListTile(this.prediction);

  void getPlaceDetials(BuildContext context, String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapAPIKey';
    final response = await FunctionsHelper.getRequest(url);
    if (response == 'failed') {
      return;
    }

    Address destinationAddress = Address(
      latitude: response['result']['geometry']['location']['lat'],
      longitude: response['result']['geometry']['location']['lng'],
      placeId: response['result']['place_id'],
      placeName: response['result']['name'],
      formattedAddress: response['result']['formatted_address'],
    );
    Provider.of<AppData>(context, listen: false).setDestinationAddress(destinationAddress);
    print(destinationAddress.latitude);
    print(destinationAddress.longitude);
    print(destinationAddress.formattedAddress);
    print(destinationAddress.placeId);
    print(destinationAddress.placeName);
    Navigator.of(context).pop('getDirection');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: Icon(Icons.location_pin),
      title: Text(prediction.mainText),
      subtitle: Text(
        prediction.secondaryText,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        getPlaceDetials(context, prediction.placeId);
      },
    );
  }
}
