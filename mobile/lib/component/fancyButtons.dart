import 'package:flutter/material.dart';
import 'package:errand_share/screens/InProgressScreen.dart';
import 'package:errand_share/screens/RequestCreateScreen.dart';
import 'package:errand_share/data/user.dart';

class FancyFab extends StatefulWidget {
  //final Function() onPressed;
  //final String tooltip;
  //final IconData icon;
  final User user;

  //FancyFab({this.onPressed, this.tooltip, this.icon,this.user});
  FancyFab(this.user);

  @override
  _FancyFabState createState() => _FancyFabState(user);
}

class _FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  User user;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  final Curve _curve = Curves.easeOut;
  final double _fabHeight = 56.0;
  _FancyFabState(this.user);

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.green[100],
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget createReq() {
    return Container(
      child: FloatingActionButton(
        heroTag: 'CreateReq',
        tooltip: 'Create Request',
        child: Icon(Icons.add),
        onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RequestCreateScreen(user)));
            }
      ),
    );
  }

  Widget checkHist() {
    return Container(
        child: FloatingActionButton(
            heroTag: 'CheckHist',
            tooltip: 'Check History',
            child: Icon(Icons.history),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => InProgress(user)));
            }));
  }

  Widget inbox() {
    return Container(
      child: FloatingActionButton(
        onPressed: null,
        tooltip: 'Inbox',
        child: Icon(Icons.inbox),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: createReq(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 1.0,
            0.0,
          ),
          child: checkHist(),
        ),
        /*Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: inbox(),
        ),*/
        toggle(),
      ],
    );
  }
}
