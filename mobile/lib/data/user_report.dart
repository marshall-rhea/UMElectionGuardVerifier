import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class UserReport {
  final String type;
  final String comment;
  final String reporterid;
  final String bountyid;
  String reportid;
  bool resolved = false;


  UserReport({
    @required this.type,
    @required this.comment,
    @required this.reporterid,
    @required this.bountyid,
    this.reportid,
    this.resolved,
  });

  UserReport.fromSnapshot(DataSnapshot snapshot) :
    reportid = snapshot.key,
    type = snapshot.value['type'],
    comment = snapshot.value['comment'],
    reporterid = snapshot.value['reporterid'],
    bountyid = snapshot.value['bountyid'],
    resolved = snapshot.value['resolved'];

  Map<String, dynamic> toJson() =>
    {
      'type': type,
      'comment': comment,
      'reporterid': reporterid,
      'bountyid': bountyid,
      'resolved': false,
    };
}
