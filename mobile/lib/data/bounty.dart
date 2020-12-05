import 'package:firebase_database/firebase_database.dart';

class Bounty{
  //which of these should be final, const, static
  String bountyid;
  String posterid;
  String bountyPrice;
  String estimatedPrice;
  String description;
  String dropOffAddrId;
  String errandAddrId;
  String pickUpTime;
  String dropOffTime;
  String creationTime;
  String progress;
  String fullfillerid;

  //check that the fields are correct 
  Bounty.fromMap(Map<String, dynamic> data) {
         bountyid = data['key'];
        posterid = data['posterid'];
        bountyPrice = data['bountyPrice'];
        estimatedPrice = data['estimatedPrice'];
        description = data['description'];
        dropOffAddrId = data['dropOffAddr'];
        errandAddrId = data['errandAddr'];
        pickUpTime = data['pickUpTime'];
        dropOffTime = data['dropOffTime'];
        creationTime = data['creationTime'];
        progress = data['progress'];
        fullfillerid = data['fullfillerid'];
  }

  //constructor for Bounty
  Bounty(this.posterid, this.bountyPrice, this.estimatedPrice, this.description,
      this.dropOffAddrId, this.errandAddrId, this.pickUpTime, this.dropOffTime, this.creationTime, this.progress);

  //parse database info
  Bounty.fromSnapShot(DataSnapshot snapshot){
        bountyid = snapshot.key;
        fullfillerid = snapshot.value['fullfillerid'];
        posterid = snapshot.value['posterid'];
        bountyPrice = snapshot.value['bountyPrice'];
        estimatedPrice = snapshot.value['estimatedPrice'];
        description = snapshot.value['description'];
        dropOffAddrId = snapshot.value['dropOffAddr'];
        errandAddrId = snapshot.value['errandAddr'];
        pickUpTime = snapshot.value['pickUpTime'];
        dropOffTime = snapshot.value['dropOffTime'];
        creationTime = snapshot.value['creationTime'];
        progress = snapshot.value['progress'];
  }


  Map<String, dynamic> toJson() => {
        'posterid': posterid,
        'bountyPrice':bountyPrice,
        'estimatedPrice': estimatedPrice,
        'description' : description,
        'dropOffAddr' : dropOffAddrId,
        'errandAddr' : errandAddrId, 
        'pickUpTime' : pickUpTime,
        'dropOffTime' : dropOffTime, 
        'creationTime' : creationTime,
        'progress' : progress,
        'fullfillerid' : fullfillerid,
      };
}
