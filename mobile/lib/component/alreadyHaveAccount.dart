//TODO: implement registration page
import 'package:flutter/material.dart';

class AlreadyHaveAccountCheck extends StatelessWidget {
  final bool login;
  final Function press;
  const AlreadyHaveAccountCheck({
    Key key,
    this.login = true,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          login ? 'Do not have an account ?' : 'Already have an account ?',
          style: TextStyle(color: Colors.black),
        ),
        GestureDetector(
            onTap: press,
            child: Text(login ? 'Sign Up' : 'Login',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)))
      ],
    );
  }
}
