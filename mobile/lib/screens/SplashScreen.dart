//TODO：implement Splash page

import 'package:errand_share/services/auth.dart';
import 'package:errand_share/screens/BountyBoard.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // This is the uid of the test user.
    // Using it lets us run the app without a runtime error
    // due to empty json object

    super.initState();
    Authenticator().signOut();
    Authenticator()
        .currentUser()
        .then((currentUser) => {
              if (currentUser == null)
                {
                  Navigator.pushReplacementNamed(context, '/login'),
                  print('No current user')
                }
              else
                {
                  print('current user exists'),
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return BountyBoard(currentUser);
                  })),
                }
            })
        .catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(color: Colors.blue),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 50.0,
                      child: Icon(
                        Icons.shopping_basket,
                        color: Colors.blueAccent,
                        size: 50.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                    ),
                    Text(
                      'ErrandShare',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                  ),
                  Text(
                    'Help your neighbours!',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    ));
  }
}
