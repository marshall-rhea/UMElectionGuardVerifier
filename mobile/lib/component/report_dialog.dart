import 'package:errand_share/data/user_report.dart';
import 'package:flutter/material.dart';
import 'package:errand_share/component/roundButton.dart';
import 'package:errand_share/data/database.dart';
import 'package:errand_share/services/auth.dart';

void ReportDialog(BuildContext context, String bountyid) async {
    return await showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
        AlertDialog(
         title: Text('Report an Issue'),
         content: SingleChildScrollView(
           child: ListBody(
             children: <Widget>[
               Text('Reason for report:'),
               RadioButtons(bountyid: bountyid),
             ],
           ),
         ),
    ));
}

class RadioButtons extends StatefulWidget {
  final String bountyid;
  RadioButtons({Key key, this.bountyid}) 
    : super(key: key);

  @override
  _RadioButtonsState createState() =>
    _RadioButtonsState(bountyid: bountyid);
}

class _RadioButtonsState extends State<RadioButtons> {
  String _choice = 'spam';
  String _comment = '';
  final String bountyid;

  _RadioButtonsState({this.bountyid});

  void unawaited(Future<void> future) {}

  Future<void> submit() async {
    final user = await Authenticator().currentUser();
    if (user != null){
      unawaited(Database().createReport(
        UserReport(
          bountyid: bountyid,
          type: _choice,
          comment: _comment,
          reporterid: user.uid,
      )));
    }
    Navigator.of(context).pop();
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Spam'),
          leading: Radio(
            value: 'spam',
            groupValue: _choice,
            onChanged: (String value){
              setState(() {
                _choice = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Inappropriate Content'),
          leading: Radio(
            value: 'inappropriate', 
            groupValue: _choice, 
            onChanged: (String value) {
              setState(() {
                _choice = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Delivery Issue'),
          leading: Radio(
            value: 'delivery', 
            groupValue: _choice, 
            onChanged: (String value) {
              setState(() {
                _choice = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Other'),
          leading: Radio(
            value: 'other', 
            groupValue: _choice, 
            onChanged: (String value) {
              setState(() {
                _choice = value;
              });
            },
          ),
        ),
        TextFormField(
          style: TextStyle(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Add a comment (optional)',
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.blue),
            ),
          ),
          keyboardType: TextInputType.multiline,
          onSaved: (value) {
            setState(() {
              _comment = value;
            });
          },
        ),
        RoundedButton(
          text: 'Submit',
          textColor: Colors.white,
          buttonColor: Colors.blue,
          press: () {unawaited(submit());},
        ),
        RoundedButton(
          text: 'Cancel',
          textColor: Colors.white,
          buttonColor: Colors.red,
          press: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
