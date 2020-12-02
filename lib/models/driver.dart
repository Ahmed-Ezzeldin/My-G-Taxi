import 'package:firebase_database/firebase_database.dart';

class Driver {
  String id;
  String name;
  String email;
  String phone;
  String carBrand;
  String carModel;
  String carNumber;
  String carColor;
  Driver(
    this.id,
    this.name,
    this.email,
    this.phone,
    this.carBrand,
    this.carModel,
    this.carNumber,
    this.carColor,
  );

  Driver.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    name = snapshot.value['name'];
    email = snapshot.value['email'];
    phone = snapshot.value['phoneNumber'];
    carBrand = snapshot.value['carBrand'];
    carModel = snapshot.value['carModel'];
    carNumber = snapshot.value['carNumber'];
    carColor = snapshot.value['carColor'];
  }
}
