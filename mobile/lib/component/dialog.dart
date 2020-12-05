import 'package:flutter/material.dart';

class Dialog extends StatelessWidget {
  final String title;
  final String content;
  final Color splashColor,buttonColor,textColor;
  const Dialog({
    this.title,
    this.content,
    this.splashColor = Colors.red,
    this.buttonColor = Colors.teal,
    this.textColor = Colors.white,

  });

  @override
  Widget build(BuildContext context) {
    // return object of type Dialog
    return AlertDialog(
      title: Text(title),
      content:  Text(content),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        new FlatButton(
          child: new Text("Close"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
      
  }
}