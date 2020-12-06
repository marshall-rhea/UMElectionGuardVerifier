import 'package:errand_share/component/alreadyHaveAccount.dart';
import 'package:errand_share/component/roundButton.dart';
import 'package:errand_share/screens/SignUpScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:errand_share/services/auth.dart';
import 'package:errand_share/screens/BountyBoard.dart';
import 'package:flutter/services.dart';
import 'package:errand_share/util/utils.dart';

import '../util/utils.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _iconAnimationController;
  Animation<double> _iconAnimation;

  final formKey = GlobalKey<FormState>();

  String _email;
  String _password;

  // Validate the the format of the input,if valid save to private variables
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  // Validate the format of the form and login
  void validateAndSubmit(Function signInFunc) {
    try{
      signInFunc().then(
        (result) => validateUser(context, result)
      );
    } catch (e){
      showAlertDialog(context, 'Something went wrong. Check your internet connection and try again.');
    }
    // if (validateAndSave()) {
    //   try {
    //     Authenticator().signInWithEmail(_email, _password)
    //       .then((result) => validateUser(context, result, false));
    //   } catch (e){
    //     print('Bad Exception: ${e}');
    //     showAlertDialog(context, 'Something went wrong. Check your internet connection and try again.');
    //   }
    // }
  }

  // init animation controller and Animation<double>
  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 500,
        ));
    _iconAnimation = CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.easeOut,
    );
    _iconAnimation.addListener(() => setState(() {}));
    _iconAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Image.asset(
                  'lib/assets/logo.png'
                )
              )
              ,
              //FlutterLogo(
                //size: _iconAnimation.value * 100,
              //),
              Form(
                  key: formKey,
                  child: Theme(
                    data: ThemeData(
                      brightness: Brightness.dark,
                      primaryColor: Colors.blue,
                      hintColor: Colors.blue,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextFormField(
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter Email',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blue),
                              ),
                              //fillColor: Colors.blue,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                value.isEmpty ? 'Email can\'t be empty' : null,
                            onSaved: (value) => _email = value,
                          ),
                          TextFormField(
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter Password',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blue),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            validator: (value) => value.isEmpty
                                ? 'Password can\'t be empty'
                                : null,
                            onSaved: (value) => _password = value,
                          ),
                          RoundedButton(
                            text: 'Login',
                            textColor: Colors.white,
                            buttonColor: Colors.blue,
                            press: () {
                              if (validateAndSave()){
                                validateAndSubmit(() => 
                                  Authenticator().signInWithEmail(_email, _password)
                                );
                              }
                            },
                          ),
                          RoundedButton(
                              text: 'Login with Google',
                              textColor: Colors.white,
                              buttonColor: Colors.blue,
                              press: () {
                                validateAndSubmit(() => 
                                  Authenticator().signInWithGoogle()
                                );
                              }
                          ),
                          RoundedButton(
                              text: 'Login with Facebook',
                              textColor: Colors.white,
                              buttonColor: Colors.blue,
                              press: () {
                                validateAndSubmit(() =>
                                  Authenticator().signInWithFacebook(context)
                                );
                              }),
                          AlreadyHaveAccountCheck(
                            press: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return SignUpScreen();
                              }));
                            },
                            login: true,
                          )
                        ],
                      ),
                    ),
                  ))
            ],
          )
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  const TextFieldContainer({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(29),
      ),
      child: child,
    );
  }
}
