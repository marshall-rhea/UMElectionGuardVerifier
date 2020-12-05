import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class User {
  int tokens = 0;
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String address = '';
  bool isNewUser = false;
  final String email;
  final String uid;
  bool isPrivileged = false;

  // Construct a new user from scratch
  User(
      {@required this.uid,
      @required this.email,
      this.firstName,
      this.lastName,
      this.tokens,
      this.address,
      this.phoneNumber,
      this.isNewUser,
      this.isPrivileged}){
          isNewUser ??= false;
      }

  // Parse database information
  User.fromSnapShot(DataSnapshot snapshot)
      : uid = snapshot.key,
        firstName = snapshot.value.containsKey('firstName')
            ? snapshot.value['firstName']
            : '',
        lastName = snapshot.value.containsKey('lastName')
            ? snapshot.value['lastName']
            : '',
        email = snapshot.value['email'],
        tokens =
            snapshot.value.containsKey('tokens') ? snapshot.value['tokens'] : 0,
        address = snapshot.value.containsKey('address')
            ? snapshot.value['address']
            : '',
        phoneNumber = snapshot.value.containsKey('phoneNumber')
            ? snapshot.value['phoneNumber']
            : '',
        isPrivileged = snapshot.value.containsKey('isPrivileged')
            ? snapshot.value['isPrivileged']
            : false;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'tokens': tokens,
        'address': address,
        'phoneNumber': phoneNumber,
        'isPrivileged': isPrivileged,
      };

  // Allows us to use User in print statements for testing
  @override
  String toString() => 'User ${uid}: ${firstName} ${lastName}, ${email}';

  @override
  bool operator ==(rhs) =>
      rhs is User &&
      uid == rhs.uid &&
      firstName == rhs.firstName &&
      lastName == rhs.lastName &&
      email == rhs.email;
}
