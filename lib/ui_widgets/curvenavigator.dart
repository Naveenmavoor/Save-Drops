import 'dart:ui';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sed/models/main.dart';
import 'package:sed/screens/homepage/down_part.dart';   
import 'package:sed/screens/user_edit/userprofile.dart';
import 'package:sed/ui_widgets/logout.dart';
import 'package:sed/ui_widgets/usage_stastics.dart';

class Redirect extends StatefulWidget {
  final MainModel model;
  Redirect(this.model);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Redirect> {
  final drawerScrimColor = Color.fromARGB(90, 100, 100, 128);
  final double drawerEdgeDragWidth = null;

  String _homeScreenText;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final DragStartBehavior drawerDragStartBehavior = DragStartBehavior.start;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _currentindex = 0;

  void _showItemDialog(message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Text('Goto usage statistics'),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentindex = 1;
                  });
                },
              )
            ],
            title: Text(message['notification']['title']),
            content: SingleChildScrollView(
              child: Text(message['notification']['body']),
            ),
          );
        });
  }

  @override
  void initState() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        _showItemDialog(message);
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      }, 
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _drawer(widget.model),
      backgroundColor: Colors.transparent,
      body: Stack(children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/blue.jpg'), fit: BoxFit.cover),
          ),
          child: BackdropFilter(
            child: Text('.'),
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          ),
        ),
        _currentindex == 0
            ? DownPart(model: widget.model, scaffoldkey: _scaffoldKey)
            : _currentindex == 1
                ? Usage_Stastics(
                    model: widget.model,
                    scaffoldKey: _scaffoldKey,
                  )
                : UserProfile(widget.model),
        Align(
          alignment: Alignment.bottomCenter,
          child: CurvedNavigationBar(
            animationDuration: Duration(milliseconds: 300),
            color: Colors.black.withOpacity(0.8),
            height: 65,
            backgroundColor: Colors.transparent,
            index: _currentindex,
            onTap: _onTapTapped,
            items: <Widget>[
              _currentindex == 0
                  ? Icon(
                      Icons.home,
                      size: 25,
                      color: Color(0xff1FFF00),
                    )
                  : Icon(
                      Icons.home,
                      size: 23,
                      color: Colors.white.withOpacity(0.5),
                    ),
              _currentindex == 1
                  ? Icon(
                      FontAwesomeIcons.chartLine,
                      size: 23,
                      color: Color(0xff1FFF00),
                    )
                  : Icon(FontAwesomeIcons.chartLine,
                      size: 20, color: Colors.white.withOpacity(0.5)),
              _currentindex == 2
                  ? Icon(
                      FontAwesomeIcons.user,
                      size: 21,
                      color: Color(0xff1FFF00),
                    )
                  : Icon(FontAwesomeIcons.user,
                      size: 19, color: Colors.white.withOpacity(0.5)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _drawer(model) => Drawer(
        child: ClipRRect(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/blue.jpg'),
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(model.uname),
                    accountEmail: Text(model.user.email),
                    decoration: BoxDecoration(),
                    currentAccountPicture: new CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xff1FFF00),
                      backgroundImage: AssetImage('assets/user.png'),
                    ),
                  ),
                  Logout(),
                  Divider()
                ],
              ),
            ),
          ),
        ),
      );

  void _onTapTapped(int index) {
    setState(() {
      _currentindex = index;
    });
  }
}

  