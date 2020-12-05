import 'package:errand_share/screens/BountyBoard.dart';
import 'package:flutter/material.dart';
import 'package:errand_share/screens/UserCreateScreen.dart';

import '../screens/BountyBoard.dart';
import '../screens/UserCreateScreen.dart';

Future<void> showAlertDialog(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
        AlertDialog(
         title: Text('Oops'),
         content: SingleChildScrollView(
           child: ListBody(
             children: <Widget>[
               Text(message),
             ],
           ),
         ),
         actions: <Widget>[
           FlatButton(
             child: Text('Ok'),
             onPressed: () {
               Navigator.of(context).pop();
             },
           )
         ],
    ));
}

void validateUser(BuildContext context, dynamic result) {
  if (result is String) {
    var code = result.substring(result.indexOf('(') + 1, result.indexOf(','));
    var message = code;
    switch (code) {
      case 'ERROR_INVALID_EMAIL':
        message = 'Check your email adress and try again.';
        break;
      case 'ERROR_USER_NOT_FOUND':
        message = 'Check your email or create an account and try again.';
        break;
      case 'ERROR_WRONG_PASSWORD':
        message = "Your email and password don't match.";
        break;
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        message = 'Looks like you already have an account. Try signing in.';
        break;
      case 'ERROR_WEAK_PASSWORD':
        message = 'Try choosing a stronger password.';
        break;
      case 'sign_in_canceled':
        return;
      default:
        message = result.substring(result.indexOf(', ') + 2, result.indexOf(', null'));
    }
    showAlertDialog(context, message);
  } else {
    var route = result.isNewUser ? UserCreateScreen(user: result) : BountyBoard(result);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: ( context) {
          return route;
        },
    ));
  }
}

// Check if text contains any string in the ban list. If so, throw exception
// otherwise do nothing.
void checkLanguage(String text){
  const banList = ['anal',
                    'anus',
                    'arse',
                    'ass',
                    'ballsack',
                    'balls',
                    'bastard',
                    'bitch',
                    'biatch',
                    'bloody',
                    'blowjob',
                    'blow job',
                    'bollock',                    
                    'bollok',
                    'boner',
                    'boob',
                    'bugger',
                    'bum',
                    'butt',
                    'buttplug',
                    'clitoris',
                    'cock',
                    'coon',
                    'crap',
                    'cunt',
                    'damn',
                    'dick',
                    'dildo',
                    'dyke',
                    'fag',
                    'feck',
                    'fellate',
                    'fellatio',
                    'felching',
                    'fuck',
                    'f u c k',
                    'fudgepacker',
                    'fudge packer',
                    'flange',
                    'Goddamn',
                    'God damn',
                    'hell',
                    'homo',
                    'jerk',
                    'jizz',
                    'knobend',
                    'knob end',
                    'labia',
                    'lmao',
                    'lmfao',
                    'muff',
                    'nigger',
                    'nigga',
                    'omg',
                    'penis',
                    'piss',
                    'poop',
                    'prick',
                    'pube',
                    'pussy',
                    'queer',
                    'scrotum',
                    'sex',
                    'shit',
                    's hit',
                    'sh1t',
                    'slut',
                    'smegma',
                    'spunk',
                    'tit',
                    'tosser',
                    'turd',
                    'twat',
                    'vagina',
                    'wank',
                    'whore',
                    'wtf',
                  ];

  for (var i = 0; i < banList.length; i++){
    var expr = RegExp('(${banList[i]})');
    if (expr.hasMatch(text)){
      throw Exception('Text has banned words');
    }
  }
}

