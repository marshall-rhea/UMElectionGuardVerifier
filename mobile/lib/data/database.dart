import 'package:errand_share/data/user.dart';
import 'package:errand_share/data/bounty.dart';
import 'package:errand_share/data/Payment.dart';
import 'package:errand_share/data/user_report.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Database {
  static final _db = FirebaseDatabase.instance;

  // Instance can be used exactly like FirebaseDatabase.
  static FirebaseDatabase get instance => _db;

  // Base read and write functions cause less repitition in the rest of the methods.
  Future<DataSnapshot> _readDatabase(String path) {
    try {
      return _db.reference().child(path).once();
    } catch (error) {
      print('Database read error: ${error}');
      return error;
    }
  }

  // This will save any object that has a toJson function.
  dynamic _writeDatabase(dynamic object, String path) async {
    try {
      await _db.reference().child(path).set(object.toJson());
      return object;
    } catch (error) {
      print('Database write error: ${error}');
      return error;
    }
  }

  // Asynchronously load a user in the background
  Future<T> getUserById<T>(String uid) async => _readDatabase('users/${uid}')
      .then((snapshot) => ((snapshot is DataSnapshot)
          ? User.fromSnapShot(snapshot)
          : snapshot));

  //asynchronously fetch bounty information
  //we can change bounty id to distance from current location for distance filtering
  //this function will only retrieve a single bounty, for alist we can use: https://stackoverflow.com/questions/57762338/how-to-return-future-list-from-datasnapshot
  Future<T> getBountyById<T>(String bountyid) =>
      _readDatabase('bounties/${bountyid}').then((snapshot) =>
          ((snapshot is DataSnapshot)
              ? Bounty.fromSnapShot(snapshot)
              : snapshot));

  Future<T> getPaymentById<T>(String paymentid) =>
      _readDatabase('payments/${paymentid}').then((snapshot) =>
          ((snapshot is DataSnapshot)
              ? Payment.fromSnapShot(snapshot)
              : snapshot));

  Future<T> getReportById<T>(String reportid) =>
    _readDatabase('reports/${reportid}').then((snapshot) => 
      (snapshot is DataSnapshot) ? UserReport.fromSnapshot(snapshot) : snapshot
    );

  //Added to collect bounty list per user
  DatabaseReference getBountyList() => _db.reference().child('bounties');

  DatabaseReference getPaymentList() => _db.reference().child('payments');

  // Add a new user or bounty to the database
  Future<T> createNewUser<T>(User user) async =>
      await _writeDatabase(user, 'users/${user.uid}');
  Future<T> createBounty<T>(Bounty bounty) async {
    try {
      // Create a new object in database.
      final ref = await _db.reference().child('bounties').push();
      // Set bountyid to be its unique db key.
      bounty.bountyid = ref.key;
      // Write data.
      return await _writeDatabase(bounty, 'bounties/${bounty.bountyid}');
    } catch (e) {
      debugPrint('connection error: ${e}');
      return e;
    }
  }

  Future<T> createReport<T>(UserReport report) async {
    try {
      final ref = await _db.reference().child('reports').push();
      report.reportid = ref.key;
      return await _writeDatabase(report, 'reports/${ref.key}');
    } catch(e) {
      debugPrint('connection error: ${e}');
      return e;
    }
  }

  //add a new Payment to the database
  Future<T> createNewPayment<T>(Payment payment) async {
      final ref = await _db.reference().child('payments').push();
      payment.paymentID = ref.key;
      return await _writeDatabase(payment, 'payments/${payment.paymentID}');
  }

  // Add or edit user info.
  // returns new user object -- technically the same as amking a new user.
  Future<T> updateUserInfo<T>(User updatedUser) => createNewUser(updatedUser);

  Future<T> realupdateUserInfo<T>(User user) =>
      _writeDatabase(user, 'users/${user.uid}');

  Future<T> updateBountyInfo<T>(Bounty bounty) =>
      _writeDatabase(bounty, 'bounties/${bounty.bountyid}');

  // Remove bounty from db
  Future<void> deleteBounty(String bountyid) =>
      _db.reference().child('bounties/${bountyid}').remove();
}
