import 'package:flutter/material.dart';
import 'package:g_taxi/global_variables.dart';
import 'package:g_taxi/helpers/functions_helper.dart';
import 'package:g_taxi/models/prediction.dart';
import 'package:g_taxi/style/my_colors.dart';
import 'package:g_taxi/widgets/prediction_list_tile.dart';

class SearchDestinationScreen extends StatefulWidget {
  static const String routeName = 'search_destination_screen';

  @override
  _SearchDestinationScreenState createState() => _SearchDestinationScreenState();
}

class _SearchDestinationScreenState extends State<SearchDestinationScreen> {
  final destinationController = TextEditingController();
  final destinationNode = FocusNode();
  List<Prediction> predictionList = [];

  void searchPlace(String placeName) async {
    if (placeName.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapAPIKey&components=country:eg';

      final response = await FunctionsHelper.getRequest(url);
      if (response == 'failed') {
        return;
      }
      if (response['status'] == 'OK') {
        var predictionsJson = response['predictions'];
        setState(() {
          predictionList = (predictionsJson as List).map((e) => Prediction.fromJson(e)).toList();
        });
      }
      print(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(destinationNode);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Set Destination'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                Image.asset('assets/images/pickicon.png', height: 18, width: 18),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    initialValue: formattedLocation != null ? formattedLocation : 'Your Location',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: MyColors.lightGrayFair,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Image.asset('assets/images/desticon.png', height: 18, width: 18),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: destinationController,
                    focusNode: destinationNode,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: MyColors.lightGrayFair,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      hintText: 'Where to go?',
                    ),
                    onChanged: (value) {
                      searchPlace(value);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: predictionList.length,
                itemBuilder: (ctx, index) => PredictionListTile(predictionList[index]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
