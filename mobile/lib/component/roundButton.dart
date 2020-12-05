import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color splashColor,buttonColor,textColor;
  const RoundedButton({
    Key key,
    this.text,
    this.press,
    this.splashColor = Colors.red,
    this.buttonColor = Colors.teal,
    this.textColor = Colors.white,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: FlatButton(
          splashColor: splashColor,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          color: buttonColor,
          onPressed: press,
          child: Text(
            text,
            style: TextStyle(color: textColor,fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}