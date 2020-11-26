import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String id;
  String name;
  String email;
  String phone;
  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
  });

  UserModel.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key; // or snapshot.value['id']
    name = snapshot.value['name'];
    email = snapshot.value['email'];
    phone = snapshot.value['phoneNumber'];
  }
}
