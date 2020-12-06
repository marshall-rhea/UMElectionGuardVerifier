import 'dart:async';

//import 'package:errand_share/component/fancyButtons.dart';
import 'package:errand_share/screens/LoginScreen.dart';
import 'package:errand_share/screens/InProgressScreen.dart';
import 'package:errand_share/screens/EditBountyScreen.dart';
import 'package:errand_share/screens/RequestCreateScreen.dart';
import 'package:errand_share/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:errand_share/services/geoService.dart';
import 'package:errand_share/data/bounty.dart';
import 'package:errand_share/data/user.dart';
import 'package:errand_share/data/database.dart';
import 'package:errand_share/screens/BountyInfo.dart';
import 'package:errand_share/screens/UserInfo.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:meta/meta.dart';

//import 'package:errand_share/screens/BountyTile.dart';

//final _backgroundColor = Colors.green[100];
//final _rowHeight = 100.0;
//final _borderRadius = BorderRadius.circular(_rowHeight / 2);

class BountyBoard extends StatefulWidget {
  //final User currUser;
  final User input;
  BountyBoard(this.input);
  @override
  _BountyBoardState createState() => _BountyBoardState(input);
}

class _BountyBoardState extends State<BountyBoard> {
  final User input;
  _BountyBoardState(this.input);
  //Tuple of Bounty and distance from current postion to the starting address
  List<Tuple2<Bounty, double>> bounties = [];
  //ScrollController _scrollController = new ScrollController();
  DatabaseReference bountyRef;
  StreamSubscription<Event> changedStream;
  StreamSubscription<Event> addedStream;
  //Bounty item;

  @override
  void initState() {
    super.initState();
    //fetch();
    /*item = Bounty(
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      ''
    );*/
    bountyRef = Database().getBountyList();
    changedStream = bountyRef.onChildChanged.listen(_onEntryChanged);
    addedStream = bountyRef.onChildAdded.listen(_onButtonPush);
    //bountyRef.onChildChanged.listen(_onEntryChanged);
    /*_scrollController.addListener(() {if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
      //if we are at the bottom, fetch more
      fetch();
    }});*/
  }

  void _onButtonPush(Event event) {
    setState(() async {
      var bounty = Bounty.fromSnapShot(event.snapshot);
      var queryRes = await GeoService().QueryDistanceCur(bounty.errandAddrId);
      bounty.errandAddrId = queryRes.address;
      bounty.dropOffAddrId =
          await GeoService().getAddrByID(bounty.dropOffAddrId);
      var pair = Tuple2<Bounty, double>(bounty, queryRes.distance);
      bounties.add(pair);
    });
  }

  // void _onEntryAdded(Event event) {
  //   setState(() {
  //     bounties.add(Bounty.fromSnapShot(event.snapshot));
  //   });
  // }

  void _onEntryChanged(Event event) {
    var old = bounties.singleWhere((entry) {
      return entry.item1.bountyid == event.snapshot.key;
    });
    setState(() async {
      var bounty = Bounty.fromSnapShot(event.snapshot);
      var queryRes = await GeoService().QueryDistanceCur(bounty.errandAddrId);
      bounty.errandAddrId = queryRes.address;
      bounty.dropOffAddrId =
          await GeoService().getAddrByID(bounty.dropOffAddrId);
      var pair = Tuple2<Bounty, double>(bounty, queryRes.distance);
      bounties[bounties.indexOf(old)] = pair;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final textStyle = Theme.of(context).textTheme.headline4;
    int token = input.tokens;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bounty Board',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      //floatingActionButton: FancyFab(input),
      resizeToAvoidBottomPadding: false,

      body: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Your Token Balance: $token",
                style: TextStyle(
                  fontSize: 20,
                  //fontSize: 30.0,
                ),
              )),
          getListTiles(context, bountyRef, bounties),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Tooltip(
                message: 'Logout',
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    print('Logout button on bottomNav pressed');
                    return showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Sign out'),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text('Do you want to sign out?'),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Sign out'),
                              onPressed: () async {
                                await addedStream.cancel();
                                await changedStream.cancel();
                                setState(() {
                                  bountyRef =
                                      addedStream = changedStream = null;
                                });
                                await Authenticator().signOut();
                                await Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) {
                                    return LoginScreen();
                                  },
                                ));
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Container(
              child: Tooltip(
                message: 'Add new Request',
                child: IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RequestCreateScreen(input)));
                  },
                ),
              ),
            ),
            Container(
              child: Tooltip(
                message: 'Check Request History',
                child: IconButton(
                  icon: Icon(Icons.history),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InProgress(input)));
                  },
                ),
              ),
            ),
            Container(
              child: Tooltip(
                message: 'Edit Bounty',
                child: IconButton(
                  icon: Icon(Icons.border_color),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditBounty(input)));
                  },
                ),
              ),
            ),
            Container(
              child: Tooltip(
                message: 'Goto Account Page',
                child: IconButton(
                  icon: Icon(Icons.account_box),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserInfo(input)));
                  },
                ),
              ),
            ),
            Container(
              child: Tooltip(
                message: 'Refresh Bounty List',
                child: IconButton(
                  icon: Icon(Icons.autorenew),
                  onPressed: () {
                    setState(() {});
                  },
                ),
              ),
            ),
            Container(
              child: Tooltip(
                message: 'Print help message',
                child: IconButton(
                  icon: Icon(Icons.help),
                  onPressed: () {
                    showAlertDialog(context);
                  },
                ),
              ),
            ),
            Container(
              child: Tooltip(
                message: 'Sort by distance',
                child: IconButton(
                  icon: Icon(Icons.sort),
                  onPressed: () {
                    setState(() {
                      bounties.sort((a, b) => a.item2.compareTo(b.item2));
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getListTiles(BuildContext context, DatabaseReference bountyRef,
      List<Tuple2<Bounty, double>> bounties) {
    return getBountyList(context, bountyRef, bounties);
  }

  Widget getBountyList(BuildContext context, DatabaseReference itemRef,
      List<Tuple2<Bounty, double>> bounties) {
    return Flexible(
        child: FirebaseAnimatedList(
      query:
          itemRef, //FirebaseDatabase.instance.reference().child('bounties').orderByChild('progress').equalTo('0'),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        print(index);
        if (bounties.length <= index) {
          return Container(width: 0.0, height: 0.0);
        }
        if (bounties[index].item1.progress == '0') {
          return ListTile(
            leading:
                /*Text('Bounty Description: ' +
                (bounties[index].description ?? 'No description')),*/
                Icon(Icons.add_shopping_cart),
            title: Text(//'Bounty Description: ' +
                (bounties[index].item1.description ?? 'No description')),
            subtitle: Text('Errand Address: ' +
                (bounties[index].item1.errandAddrId ?? 'No errand Addr') +
                '\nPayout: ' +
                (bounties[index].item1.bountyPrice ?? 'No Bounty price') +
                '\nDistance: ' +
                bounties[index].item2.toString() +
                " miles"),
            trailing: Icon(Icons.keyboard_arrow_right),
            dense: true,
            isThreeLine: true,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BountyInfo(bounties[index].item1, input)));
            },
          );
        } else {
          return Container(width: 0.0, height: 0.0);
        }
      },
    ));
  }

  Widget showAlertDialog(BuildContext context) {
    // set up the buttons
    /*Widget cancelButton = FlatButton(
    child: Text('Cancel'),
    onPressed:  () {},
  );*/
    Widget continueButton = FlatButton(
      child: Text('Continue'),
      onPressed: () {},
    );

    // set up the AlertDialog
    var alert = AlertDialog(
      title: Text('BountyBoard FAQ'),
      content: Text(
          'This screen displays unaccepted bounties in your area. You can press any of the bounty tiles to see more information. Tap "accept" to accept a bounty.'),
      actions: [
        //cancelButton,
        //continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
