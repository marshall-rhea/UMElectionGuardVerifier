//TODO: implement registration page
import 'package:errand_share/component/alreadyHaveAccount.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:errand_share/services/auth.dart';
import 'package:errand_share/component/roundButton.dart';
import 'package:errand_share/screens/UserCreateScreen.dart';
import 'package:errand_share/util/utils.dart';
import '../util/utils.dart';
import 'LoginScreen.dart';

class SignUpScreen extends StatefulWidget{

  @override
  State createState() => SignUpScreenState();
}

class SignUpScreenState extends  State<SignUpScreen> {

  final formKey = GlobalKey<FormState>();

  String _email;
  String _password;

  // Validate the the format of the input,if valid save to private variables
  bool validateAndSave(){
    final form = formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    return false;
  }

  // Validate the format of the form and Sign up
  void validateAndSubmit() {
    if(validateAndSave()){
      try {
          Authenticator().createAccountWithEmail(_email, _password).then(
          (result) => validateUser(context, result));
      } catch(_) {
          showAlertDialog(context, 'Something went wrong. Check your internet connection and try again.');
      }  
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
                            onSaved: (value)=>_email = value,
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
                            validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
                            onSaved: (value)=>_password = value,
                          ),
                          RoundedButton(
                            text: 'Sign Up',
                            textColor: Colors.white,
                            buttonColor: Colors.blue,
                            press: validateAndSubmit,
                          ),
                          AlreadyHaveAccountCheck(
                            press: (){Navigator.push(
                              context,MaterialPageRoute(builder: (context){return LoginScreen();}));
                            },
                            login: false,
                          )
                        ],
                      ),
                    ),
                  )
              )
            ],
          )

        ],

      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


}
