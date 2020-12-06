/*import 'package:errand_share/data/bounty.dart';
import 'package:errand_share/data/user.dart';
import 'package:errand_share/data/database.dart';

class BountyList{
  List<Bounty> bountyList;

  factory BountyList.fromMap(Map<dynamic,dynamic> data){
    return BountyList(
      bountyList: parseBounty(data)
    )
  }

  static List<Bounty> parseBounty(data){
    var bList = data as List;
    List<Bounty> bountyList = bList.map((e) => Bounty.fromMap(e)).toList();
    return bountyList;
  }
}*/
