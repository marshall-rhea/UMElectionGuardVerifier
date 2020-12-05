import 'dart:async';
import 'dart:developer';

//import 'package:errand_share/component/fancyButtons.dart';
import 'package:errand_share/data/bountyWrapper.dart';
import 'package:errand_share/data/database.dart';
import 'package:firebase_database/firebase_database.dart';

class BountyProvider {
  List<BountyWrapper> listItems = [];

  Future<List<BountyWrapper>> fetchList() async {
    listItems.clear();
    DataSnapshot dataSnapshot = await Database().getBountyList().once();
    Map<dynamic, dynamic> jsonResponse = dataSnapshot.value;

    var blist = List<Map<String, dynamic>>();

    jsonResponse.forEach((key, value) {
      var temp = Map<String, dynamic>.from(value);
      blist.add(temp);
    });

    blist.forEach((element) async {
      BountyWrapper.create(element).then((bw) => {
            listItems.add(bw),
            log(listItems.length.toString()),
          });
    });

    // var bwList = blist.map((b) async => await BountyWrapper.create(b));
    // var rawbwList = await Future.wait(bwList);

    // listItems.addAll(rawbwList);

    return listItems;
  }

  Future<void> onChildAdded(Event event) async {
    var bw = await BountyWrapper.createFromSnapshot(event.snapshot);
    listItems.add(bw);
  }

  Future<void> onChildChanged(Event event) async {
    var old = listItems.singleWhere((entry) {
      return entry.bounty.bountyid == event.snapshot.key;
    });
    var bw = await BountyWrapper.createFromSnapshot(event.snapshot);
    listItems[listItems.indexOf(old)] = bw;
  }
}
