import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fptbooking_app/constants.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  static const int SHOWING_VIEW = 1;
  static const int IN_FIREBASE_LOGIN_PROCESS = 2;
  int _state = SHOWING_VIEW;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LoginContext _loginContext;

  @override
  Widget build(BuildContext context) {
    _loginContext = Provider.of<LoginContext>(context, listen: false);
    if (_isInFirebaseLoginProcess()) {
      _handleInFirebaseLoginProcess(context);
      return _buildInFirebaseLoginProcess(context);
    }
    _handleShowingView(context);
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void _handleShowingView(BuildContext context) {}

  Widget _buildShowingViewWidget(BuildContext context) {
    return _loginView();
  }

  //isInFirebaseLoginProcess
  bool _isInFirebaseLoginProcess() => _state == IN_FIREBASE_LOGIN_PROCESS;

  void _handleInFirebaseLoginProcess(BuildContext context) {}

  Widget _buildInFirebaseLoginProcess(BuildContext context) {
    return LoadingModal(
      isLoading: true,
      child: _loginView(),
    );
  }

  //handle methods
  Future<void> _onSignInFinished(FirebaseUser user) async {
    if (user == null) return;
    IdTokenResult fbTokenResult = await user.getIdToken(refresh: true);
    String fbToken = fbTokenResult.token;
    print(fbToken);
    _signInServer(fbToken).then((success) {
      if (success) {
        _loginContext.loggedIn();
        return;
      }
      setState(() {
        _state = SHOWING_VIEW;
      });
    }).catchError(_onSignInError);
  }

  Future<bool> _signInServer(String fbToken) async {
    var url = Constants.API_URL + '/api/users/login';
    var response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "grant_type": "firebase_token",
          "firebase_token": fbToken,
          "scope": "roles"
        }));
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(Constants.TOKEN_DATA_KEY, response.body);
      return true;
    } else if (response.statusCode != 500) {
      var result = jsonDecode(response.body);
      print(result);
      var validationData = result["data"];
      var mess = <String>[];
      for (dynamic o in validationData) mess.add(o["message"] as String);
      DialogHelper.showMessage(
          context: context, title: "Sorry", contents: mess);
      return false;
    }
    var result = jsonDecode(response.body);
    print(result);
    DialogHelper.showUnknownError(context: this.context);
    return false;
  }

  void _onSignInError(Object e) {
    print(e);
    DialogHelper.showUnknownError(context: this.context);
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      setState(() {
        _state = SHOWING_VIEW;
      });
      return null;
    }
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
    if (_isInFirebaseLoginProcess()) return;
    setState(() {
      _state = IN_FIREBASE_LOGIN_PROCESS;
    });
    _handleSignIn().then(_onSignInFinished).catchError(_onSignInError);
  }

  //widgets
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

  Widget _loginView() {
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
}
