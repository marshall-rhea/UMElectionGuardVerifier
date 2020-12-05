import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

enum _PaymentType{pending, completed, canceled, refunded}

String _typeToString(_PaymentType t){
  switch (t) {
    case _PaymentType.pending:
      return 'pending';
    case _PaymentType.completed:
      return 'completed';
    case _PaymentType.canceled:
      return 'canceled';
    case _PaymentType.refunded:
      return 'refunded';
    default:
      return '';
  }
}

_PaymentType _stringToType(String t){
  switch (t) {
    case 'pending':
      return _PaymentType.pending;
    case 'completed':
      return _PaymentType.completed;
    case 'canceled':
      return _PaymentType.canceled;
    case 'refunded':
      return _PaymentType.refunded;
    default:
      return null;
  }
}

class Payment {
  String fromID;
  String toID;
  String paymentID;
  String amount;
  _PaymentType status = _PaymentType.pending;

  String get paymentId => paymentID;

  Payment({
    @required this.fromID,
    @required this.toID,
    @required this.amount,
    this.paymentID,
  });

  // Parse database information
  Payment.fromSnapShot(DataSnapshot snapshot)
      : fromID = snapshot.value.containsKey('fromId') ? snapshot.value['fromId'] : '',
        toID = snapshot.value.containsKey('toID') ? snapshot.value['toID'] : '',
        paymentID = snapshot.key,
        amount = snapshot.value.containsKey('amount')
            ? snapshot.value['amount']
            : '',
        status = snapshot.value.containsKey('status') ? _stringToType(snapshot.value['status']) : null;
  Map<String, dynamic> toJson() => 
    {
      'fromID': fromID,
      'toID': toID,
      'amount': amount,
      'status': _typeToString(status),
    };

  // Allows us to use User in print statements for testing
  @override
  String toString() =>
      'Payment ${fromID}: ${toID} ${paymentID}, ${amount}';

  @override
  bool operator ==(rhs) =>
      paymentID == rhs.paymentID;
}
