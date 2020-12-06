import 'package:errand_share/screens/UserEditScreen.dart';
import 'package:flutter/material.dart';
import 'package:errand_share/data/bounty.dart';
import 'package:errand_share/data/database.dart';
import 'package:errand_share/data/user.dart';
import 'package:errand_share/data/PaymentsRepository.dart';

import 'package:square_in_app_payments/models.dart';
import 'package:square_in_app_payments/in_app_payments.dart';

class UserInfo extends StatelessWidget {
  final User user;
  UserInfo(this.user);

  void _pay() async {
    await InAppPayments.setSquareApplicationId(
        'sandbox-sq0idb-QDF61H5hSki0NHwpqtP8gQ');
    await InAppPayments.startCardEntryFlow(
      onCardNonceRequestSuccess: (CardDetails result) {
        try {
          print('success!');
          print(result
              .nonce); //send the resultnonce and other info to firebase to Square backend
          var chargeSuccess = PaymentsRepo.actuallyMakeTheCharge(result.nonce);
          if (chargeSuccess != true) {
            //throw new RemoteError(chargeSuccess); //throw error
            print('charge failed');
          }
          InAppPayments.completeCardEntry(
            onCardEntryComplete: _cardEntryComplete,
          );
        } catch (ex) {
          InAppPayments.showCardNonceProcessingError(ex.toString());
        }
      },
      //_cardNonceSuccess,
      onCardEntryCancel: _cardEntryCancel,
    );
  }

  void _cardNonceSuccess(CardDetails result) {
    print(result.nonce); //send result.nonce to backend, one time use token

    InAppPayments.completeCardEntry(
      onCardEntryComplete: _cardEntryComplete,
    );
  }

  void _cardEntryComplete() {
    //successfully entered card
    print('cardEntryComplete() called');
  }

  void _cardEntryCancel() {
    //can leave empty?
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      title: 'Your Account Information',
      //theme: ThemeData.dark(),

      home: Scaffold(
        appBar: AppBar(
          title: Text('Your Account Information'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, true);
              }),
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('User ID: ' + (user.uid ?? 'N/A'))),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('First Name: ' + (user.firstName ?? 'N/A'))),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Last Name: ' + (user.lastName ?? 'N/A'))),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Email: ' + (user.email ?? 'N/A'))),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Address: ' + (user.address ?? 'N/A'))),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Phone Number: ' + (user.phoneNumber ?? 'N/A'))),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                      'Token Balance: ' + (user.tokens.toString() ?? 'N/A'))),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => UserEditScreen(user)));
                    },
                    color: Colors.blue,
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      // Replace with a Row for horizontal icon + text
                      children: <Widget>[Text('Edit')],
                    ),
                  )),
            ]),
        floatingActionButton: FloatingActionButton(
          onPressed: _pay,
          tooltip: 'Pay with Square',
          child: Icon(Icons.payment),
        ),
      ),
    );
  }
}
