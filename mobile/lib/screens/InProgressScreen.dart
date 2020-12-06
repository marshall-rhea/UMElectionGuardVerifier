import 'package:flutter/material.dart';
import 'package:errand_share/data/bounty.dart';
import 'package:errand_share/data/user.dart';
import 'package:errand_share/data/database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:errand_share/screens/BountyInfo.dart';

class InProgress extends StatefulWidget {
  final User user;
  InProgress(this.user);
  @override
  _InProgressState createState() => _InProgressState(user);
}

class _InProgressState extends State<InProgress> {
  User user;
  _InProgressState(this.user);
  List<Bounty> items = [];
  Bounty item;
  DatabaseReference itemRef;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = Bounty('', '','','','','','', '', '','');
    itemRef = Database().getBountyList();
    itemRef.onChildAdded.listen(_onEntryAdded);
    itemRef.onChildChanged.listen(_onEntryChanged);
  }

  void _onEntryAdded(Event event) {
    setState(() {
      items.add(Bounty.fromSnapShot(event.snapshot));
    });
  }

  void _onEntryChanged(Event event) {
    var old = items.singleWhere((entry) {
      return entry.bountyid == event.snapshot.key;
    });
    setState(() {
      items[items.indexOf(old)] = Bounty.fromSnapShot(event.snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final TextStyle textStyle = Theme.of(context).textTheme.headline4;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon:  Icon(Icons.arrow_back),
            onPressed: (){Navigator.pop(context,true);}
        ),
          title: const Text('Your Bounties in Progress'),
        ),
        body:
        Column(
         //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child:
          ToggleButtons(
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width/2 - 20.0,
                      child: Text('I accepted:',textAlign: TextAlign.center,)
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width/2 - 20.0,
                      child: Text('I posted:',textAlign: TextAlign.center,)
                  ),
                ],
                onPressed: (int index) {
                  setState(() {
                    for (var buttonIndex = 0; buttonIndex < 2; buttonIndex++) {
                      if (buttonIndex == index) {
                        choices[buttonIndex] = true;
                      } else {
                        choices[buttonIndex] = false;
                      }
                    }
                  });
                },
                isSelected: choices,
              ),
            ),
            /*
            FutureBuilder(
              future: firebase,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return getCustomContainer();
              },
            ) //This connects to our database
            */
             getListTiles(context, itemRef, items, user),

      ],
        ),
      ),
      );
  }
}

Widget getListTiles(BuildContext context, DatabaseReference itemRef, List<Bounty> items, User user) {
  if (choices[0] == true){
    return getAcceptedList(context, itemRef, items, user);
  } else {
    return getPostedList(context, itemRef, items, user);
  }
}

Widget getAcceptedList(BuildContext context, DatabaseReference itemRef, List<Bounty> items, User user) {
  return   Flexible(
    child: FirebaseAnimatedList(
      query: itemRef,//FirebaseDatabase.instance.reference().child('bounties').orderByChild('progress').equalTo('1'),
      // ignore: missing_return
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        //print("uID:"+user.uid);
        //print(items[index].fullfillerid);
          if(user.uid == items[index].fullfillerid && items[index].progress == '1'){
            //if (items[index].progress == '1') {
        return ListTile(
          leading:
          /*Text('Bounty Description: ' +
                (bounties[index].description ?? 'No description')),*/
          Icon(Icons.add_shopping_cart),
          title: Text(//'Bounty Description: ' +
              (items[index].description ?? 'No description')),
          subtitle: Text('Errand Address: ' +
              (items[index].errandAddrId ?? 'No errand Addr') +
              '\nPayout: ' +
              (items[index].bountyPrice ?? 'No Bounty price')),
          trailing: Icon(Icons.keyboard_arrow_right),
          dense: true,
          isThreeLine: true,
          enabled: (items[index].progress == '1'),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BountyInfo(items[index],user)
                ));
          },
        );}//}
          else{
            return Container(width: 0.0, height: 0.0);
          }
      },
    ),
  );
}
  Widget getPostedList(BuildContext context, DatabaseReference itemRef, List<Bounty> items, User user) {
    return   Flexible(
      child: FirebaseAnimatedList(
        query: itemRef,
        // ignore: missing_return
        itemBuilder: (BuildContext context, DataSnapshot snapshot,
            Animation<double> animation, int index) {
      if(user.uid == items[index].posterid && items[index].progress != '0'){
          return ListTile(
            leading:
            /*Text('Bounty Description: ' +
                (bounties[index].description ?? 'No description')),*/
            Icon(Icons.add_shopping_cart),
            title: Text(//'Bounty Description: ' +
                (items[index].description ?? 'No description')),
            subtitle: Text('Errand Address: ' +
                (items[index].errandAddrId ?? 'No errand Addr') +
                '\nPayout: ' +
                (items[index].bountyPrice ?? 'No Bounty price')),
            trailing: Icon(Icons.keyboard_arrow_right),
            enabled: (items[index].progress == '1'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BountyInfo(items[index],user)
                  ));
            },
          );}
      else{
        return Container(width: 0.0, height: 0.0);
      }
        },
      ),
    );
  }

  List<bool> choices = [true, false];

  /*
  Backup
  import 'package:flutter/material.dart';
import 'package:errand_share/data/bounty.dart';
import 'package:errand_share/data/database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
// import 'package:firebase_core/firebase_core.dart'; not nessecary


class BountyInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  List<Bounty> items = [];
  Bounty item;
  DatabaseReference itemRef;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    item = Bounty('', '','','','','','', '', '',);
    itemRef = Database().getBountyList();
    itemRef.onChildAdded.listen(_onEntryAdded);
    itemRef.onChildChanged.listen(_onEntryChanged);
  }

  void _onEntryAdded(Event event) {
    setState(() {
      items.add(Bounty.fromSnapShot(event.snapshot));
    });
  }

  void _onEntryChanged(Event event) {
    var old = items.singleWhere((entry) {
      return entry.bountyid == event.snapshot.key;
    });
    setState(() {
      items[items.indexOf(old)] = Bounty.fromSnapShot(event.snapshot);
    });
  }
/*
  void handleSubmit() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      itemRef.push().set(Bounty.toJson());

    }
  }
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon:  Icon(Icons.arrow_back),
            onPressed: (){Navigator.pop(context,true);}
        ),
        title: Text('Bounty List'),
      ),
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          /*
          Flexible(
            flex: 0,
            child: Center(
              child: Form(
                key: formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.info),
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => item.progress = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.info),
                      title: TextFormField(
                        initialValue: '',
                        onSaved: (val) => item.progress = val,
                        validator: (val) => val == "" ? val : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        //handleSubmit();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          */
          Flexible(
            child: FirebaseAnimatedList(
              query: itemRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return ListTile(
                  leading: Text(items[index].fullfillerid ?? 'No Name'),
                  title: Text(items[index].posterid ?? 'No Name'),
                  subtitle: Text(items[index].bountyid ?? 'No Bounty id'),
                  onTap: (){

                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

   */



