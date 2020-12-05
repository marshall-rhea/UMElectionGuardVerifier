import 'package:errand_share/component/roundButton.dart';
import 'package:errand_share/data/database.dart';
import 'package:errand_share/data/user.dart';
import 'package:errand_share/screens/BountyBoard.dart';
import 'package:errand_share/screens/SignUpScreen.dart';
import 'package:errand_share/services/geoService.dart';
import 'package:flutter/material.dart';

class UserEditScreen extends StatefulWidget {
  final User user;

  UserEditScreen(
    this.user,
  );

  @override
  State createState() => _UserEditScreen(user);
}

// TODO: what if the user register but does not finishe the perosnnal information?

class _UserEditScreen extends State<UserEditScreen> {
  User user;
  _UserEditScreen(this.user);
  bool _checked = false;
  final formKey = GlobalKey<FormState>();
  var address_controller = TextEditingController();

  @override
  void initState() {
    address_controller.text = user.address;

    super.initState();
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    address_controller.dispose();
    super.dispose();
  }

  // Validate the format of the form and login
  void validateAndSubmit(User user) {
    if (validateAndSave()) {
      //widget.user.address = _address;
      //widget.user.firstName = _firstName;
      //widget.user.lastName = _lastName;
      //widget.user.phoneNumber = _phoneNumber;
      //widget.user.lastName = _lastName;
      //Every account starts with 5 tokens
      //widget.user.tokens = 5;

      Database().realupdateUserInfo(user).then(
          (user) => {print('uploaded user'), Navigator.pop(context, true)});
    } else {
      return;
    }
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
      title: Text('AtRiskConfirmation'),
      content: Text(
          'You have indicated that you are an at risk user needing assistance. You given tokenless request posting privileges but must be confirmed before proceeding.'),
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

  void cancle() {
    //TODO: Update the Navigator to the correct page;
    resetForm();
    Navigator.pop(context, true);
  }

  void resetForm() {
    formKey.currentState.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(padding: EdgeInsets.all(10.0)),
                Form(
                    key: formKey,
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: TextFormField(
                                  initialValue: user.firstName,
                                  decoration: InputDecoration(
                                      labelText: 'First Name',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => value.isEmpty
                                      ? 'First Name can\'t be empty'
                                      : null,
                                  onSaved: (value) => user.firstName = value,
                                ),
                              ),
                              Padding(padding: EdgeInsets.all(10.0)),
                              Flexible(
                                child: TextFormField(
                                  initialValue: user.lastName,
                                  decoration: InputDecoration(
                                      labelText: 'Last Name',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => value.isEmpty
                                      ? 'Last Name can\'t be empty'
                                      : null,
                                  onSaved: (value) => user.lastName = value,
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.all(20.0)),
                          TextFormField(
                            controller: address_controller,
                            readOnly: true,
                            decoration: InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value.isEmpty
                                ? 'Address can\'t be empty'
                                : null,
                            onTap: () {
                              GeoService()
                                  .addressAutoFill(context)
                                  .then((prediction) => {
                                        if (prediction != null)
                                          {
                                            setState(() {
                                              address_controller.text =
                                                  prediction.item1;
                                              user.address = prediction.item2;
                                            }),
                                          }
                                        else
                                          {
                                            setState(() {
                                              address_controller.clear();
                                            }),
                                          }
                                      });
                            },
                          ),
                          Padding(padding: EdgeInsets.all(20.0)),
                          TextFormField(
                            initialValue: user.phoneNumber,
                            decoration: InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value.isEmpty
                                ? 'Phone Number can\'t be empty'
                                : null,
                            onSaved: (value) => user.phoneNumber = value,
                          ),
                          CheckboxListTile(
                            title: Text('Are you an At Risk user?'),
                            controlAffinity: ListTileControlAffinity.trailing,
                            value: _checked,
                            onChanged: (bool value) {
                              showAlertDialog(context);
                              setState(() {
                                _checked = value;
                              });
                            },
                          ),
                        ],
                      ),
                    )),
                Padding(padding: EdgeInsets.all(10.0)),
                Expanded(
                    child: RoundedButton(
                  text: 'Post',
                  buttonColor: Colors.blue,
                  textColor: Colors.white,
                  press: () {
                    if (validateAndSave()) {
                      //widget.user.address = _address;
                      //widget.user.firstName = _firstName;
                      //widget.user.lastName = _lastName;
                      //widget.user.phoneNumber = _phoneNumber;
                      //widget.user.lastName = _lastName;
                      //Every account starts with 5 tokens
                      //widget.user.tokens = 5;
                      user.isPrivileged = _checked;
                      Database().realupdateUserInfo(user).then((user) => {
                            print('uploaded user'),
                            Navigator.pop(context, true)
                          });
                    } else {
                      return;
                    }
                  },
                )),
                Padding(padding: EdgeInsets.all(10.0)),
                Expanded(
                    child: RoundedButton(
                  text: 'Cancel',
                  buttonColor: Colors.grey,
                  textColor: Colors.black,
                  press: cancle,
                )),
                Padding(padding: EdgeInsets.all(10.0)),
              ]),
        ],
      ),
    );
  }
}
