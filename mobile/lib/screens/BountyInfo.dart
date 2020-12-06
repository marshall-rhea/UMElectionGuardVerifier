import 'package:errand_share/component/report_dialog.dart';
import 'package:flutter/material.dart';
import 'package:errand_share/data/bounty.dart';
import 'package:errand_share/data/database.dart';
import 'package:errand_share/data/user.dart';

class BountyInfo extends StatelessWidget {
  final Bounty input;
  final User user;
  BountyInfo(this.input, this.user);
  @override
  Widget build(BuildContext context) {
    var _onPressedacc;
    var _onPressedcomp;
    if (input.progress == '0') {
      _onPressedacc =() {
        input.progress = '1';
        input.fullfillerid = user.uid;
        Database().updateBountyInfo(input);
        Navigator.pop(context, true);
        //Navigator.pop(context);
        print('Bounty Accepted');
      };
    }
    else{
      _onPressedacc = null;
    }

    if (input.fullfillerid == user.uid) {
      _onPressedcomp =() async {
        input.progress = '2';
        print(user.tokens);
        user.tokens = user.tokens + int.parse(input.bountyPrice);
        print(user.tokens);
        Database().updateBountyInfo(input);
        Database().realupdateUserInfo(user);
        var poster = await Database().getUserById(input.posterid);
        poster.tokens = poster.tokens - int.parse(input.bountyPrice);
        Database().realupdateUserInfo(poster);
        Navigator.pop(context, true);
        print('Bounty Complete');
      };
    }
    else{
      _onPressedcomp = null;
    }

    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      title: 'Your Bounty Information',
      //theme: ThemeData.dark(),

      home: Scaffold(
        appBar: AppBar(
          title: Text('Your Bounty Information'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, true);
              }),
        ),
        body:

        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                  Text('Description: ' + (input.description ?? 'N/A'))),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                  Text('Estimate price: ' + (input.estimatedPrice ?? 'N/A'))),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                  Text('Errand Address: ' + (input.errandAddrId ?? 'N/A'))),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                  Text('Drop-off Address: ' + (input.dropOffAddrId ?? 'N/A'))),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                  Text('Drop-off time: ' + (input.dropOffTime ?? 'N/A'))),
              FlatButton(
                onPressed: _onPressedacc,
                color: Colors.blue,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[Text('Accept')],
                ),
              ),
              FlatButton(

                onPressed: _onPressedcomp,
                color: Colors.blue,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  // Replace with a Row for horizontal icon + text
                  children: <Widget>[Text('Complete')],
                ),
              ),
              FlatButton(
                onPressed: () => ReportDialog(context, input.bountyid), 
                child: Column(children: <Widget>[Text('Report')],),
                color: Colors.red,
                padding: EdgeInsets.all(10.0),
               )
            ]),
      ),
    );
  }
}
