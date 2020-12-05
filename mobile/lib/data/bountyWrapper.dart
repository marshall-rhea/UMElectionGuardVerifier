import 'package:errand_share/data/bounty.dart';
import 'package:errand_share/services/geoService.dart';
import 'package:firebase_database/firebase_database.dart';

class BountyWrapper {
  Bounty bounty;
  num distance;
  String dropOffAddr;
  String errandAddr;

  BountyWrapper._create(Bounty bounty) {
    this.bounty = bounty;
  }

  static Future<BountyWrapper> create(Map<String, dynamic> data) async {
    var bounty = Bounty.fromMap(data);
    var bw = BountyWrapper._create(bounty);
    bw.dropOffAddr = await _fetchAddress(bw.bounty.dropOffAddrId);
    var res = await _calculateDistance(bw.bounty.errandAddrId);

    bw.errandAddr = res.address;
    bw.distance = res.distance;
    return bw;
  }

  static Future<BountyWrapper> createFromSnapshot(DataSnapshot snapshot) async {
    var bounty = Bounty.fromSnapShot(snapshot);
    var bw = BountyWrapper._create(bounty);
    bw.dropOffAddr = await _fetchAddress(bounty.dropOffAddrId);
    var res = await _calculateDistance(bounty.errandAddrId);

    bw.errandAddr = res.address;
    bw.distance = res.distance;

    return bw;
  }

  static Future<BountyWrapper> createFromBounty(Bounty bounty) async {
    var bw = BountyWrapper._create(bounty);
    bw.dropOffAddr = await _fetchAddress(bounty.dropOffAddrId);
    var res = await _calculateDistance(bounty.errandAddrId);

    bw.errandAddr = res.address;
    bw.distance = res.distance;

    return bw;
  }
}

Future<String> _fetchAddress(String addressId) async {
  var queryRes = await GeoService().getAddrByID(addressId);
  return queryRes;
}

Future<GeoQueryResult> _calculateDistance(String errandAddrId) async {
  var queryRes = await GeoService().QueryDistanceCur(errandAddrId);
  return queryRes;
}
