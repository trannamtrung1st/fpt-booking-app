import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  static const int NOT_LOGGED_IN = 1;
  static const int IN_FIREBASE_LOGIN_PROCESS = 2;
  static const int WAITING_SERVER_CONFIRMED = 3;
  static const int LOGGED_IN_SUCESSFULLY = 4;
  int _state = NOT_LOGGED_IN;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    if (_state == WAITING_SERVER_CONFIRMED) {
      //send token to server
    }

    // Material is a conceptual piece of paper on which the UI appears.
    return Material(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset("assets/fpt-logo.png"),
            ),
            Text('Instant booking for your need',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: _signInButton(),
            )
          ],
        ),
      ),
    );
  }

  void _onSignInSuccessfully(FirebaseUser user) {
    print(user);
  }

  void _onSignInError(Object e) {
    print(e);
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  void _onSignInPressed() {
    if (_state == IN_FIREBASE_LOGIN_PROCESS) return;
    _state = IN_FIREBASE_LOGIN_PROCESS;
    _handleSignIn().then(_onSignInSuccessfully).catchError(_onSignInError);
  }

  Widget _signInButton() {
    return FlatButton(
      padding: EdgeInsets.zero,
      splashColor: Colors.grey,
      onPressed: _onSignInPressed,
      color: Colors.blue,
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.white,
              margin: EdgeInsets.all(1),
              padding: EdgeInsets.all(4),
              child: Image(
                  image: AssetImage("assets/google-logo.png"), height: 35.0),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                'Sign in with @fpt.edu.vn',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
