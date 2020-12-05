import 'package:errand_share/component/roundButton.dart';
import 'package:errand_share/data/database.dart';
import 'package:errand_share/data/user.dart';
import 'package:errand_share/screens/BountyBoard.dart';
import 'package:errand_share/screens/SignUpScreen.dart';
import 'package:errand_share/services/geoService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserCreateScreen extends StatefulWidget {
  final User user;

  UserCreateScreen({
    @required this.user,
  });

  @override
  State createState() => _UserCreateScreen(user);
}

// TODO: what if the user register but does not finishe the perosnnal information?

class _UserCreateScreen extends State<UserCreateScreen> {
  User user;
  _UserCreateScreen(this.user);
  final formKey = GlobalKey<FormState>();
  var address_controller = TextEditingController();

  String _firstName;
  String _lastName;
  String _address;
  String _phoneNumber;

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
  void validateAndSubmit() {
    if (validateAndSave()) {
      widget.user.address = _address;
      widget.user.firstName = _firstName;
      widget.user.lastName = _lastName;
      widget.user.phoneNumber = _phoneNumber;
      widget.user.lastName = _lastName;
      //Every account starts with 5 tokens
      widget.user.tokens = 5;

      Database().createNewUser(widget.user).then((user) => {
            print('uploaded user'),
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return BountyBoard(user);
            }))
          });
    } else {
      return;
    }
  }

  void cancle() {
    //TODO: Update the Navigator to the correct page;
    resetForm();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SignUpScreen();
    }));
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
                                decoration: InputDecoration(
                                    labelText: 'First Name',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0))),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value.isEmpty
                                    ? 'First Name can\'t be empty'
                                    : null,
                                onSaved: (value) => _firstName = value,
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(10.0)),
                            Flexible(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Last Name',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0))),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value.isEmpty
                                    ? 'Last Name can\'t be empty'
                                    : null,
                                onSaved: (value) => _lastName = value,
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
                          validator: (value) =>
                              value.isEmpty ? 'Address can\'t be empty' : null,
                          onTap: () {
                            GeoService()
                                .addressAutoFill(context)
                                .then((prediction) => {
                                      if (prediction != null)
                                        {
                                          setState(() {
                                            address_controller.text =
                                                prediction.item1;
                                            _address = prediction.item2;
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
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(10),
                            WhitelistingTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value.isEmpty
                              ? 'Phone Number can\'t be empty'
                              : null,
                          onSaved: (value) => _phoneNumber = value,
                        ),
                      ],
                    ),
                  )),
              Row(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(10.0)),
                  Expanded(
                    child: RoundedButton(
                      text: 'Cancel',
                      buttonColor: Colors.grey,
                      textColor: Colors.black,
                      press: cancle,
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(10.0)),
                  Expanded(
                    child: RoundedButton(
                      text: 'Post',
                      buttonColor: Colors.orange,
                      textColor: Colors.white,
                      press: validateAndSubmit,
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(10.0)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
