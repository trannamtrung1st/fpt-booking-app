import 'package:flutter/material.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/repos/user_repo.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  static const int SHOWING_VIEW = 1;
  static const int IN_FIREBASE_LOGIN_PROCESS = 2;
  int _state = SHOWING_VIEW;

  LoginContext loginContext;
  _LoginViewPresenter _presenter;

  @override
  Widget build(BuildContext context) {
    this.loginContext = Provider.of<LoginContext>(context, listen: false);
    _presenter = _LoginViewPresenter(view: this);
    if (isInFirebaseLoginProcess()) {
      return _buildInFirebaseLoginProcess(context);
    }
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  Widget _buildShowingViewWidget(BuildContext context) {
    return LoadingModal(
      isLoading: false,
      child: _loginView(),
    );
  }

  //isInFirebaseLoginProcess
  bool isInFirebaseLoginProcess() => _state == IN_FIREBASE_LOGIN_PROCESS;

  void setInFirebaseLoginProcessState() => setState(() {
        _state = IN_FIREBASE_LOGIN_PROCESS;
      });

  Widget _buildInFirebaseLoginProcess(BuildContext context) {
    return LoadingModal(
      isLoading: true,
      child: _loginView(),
    );
  }

  void showInvalidMessages(List<String> mess) {
    DialogHelper.showMessage(context: context, title: "Sorry", contents: mess);
  }

  void showError() {
    DialogHelper.showUnknownError(context: this.context);
  }

  //widgets
  Widget _signInButton() {
    return FlatButton(
      padding: EdgeInsets.zero,
      splashColor: Colors.grey,
      onPressed: _presenter.onSignInPressed,
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
    );
  }
}

class _LoginViewPresenter {
  _LoginViewState view;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LoginContext _loginContext;

  _LoginViewPresenter({this.view}) {
    _loginContext = view.loginContext;
  }

  void _onSignInFinished(FirebaseUser user) async {
    if (user == null) return;
    IdTokenResult fbTokenResult = await user.getIdToken(refresh: true);
    String fbToken = fbTokenResult.token;
    print(fbToken);
    var success = false;
    _signInServer(
            fbToken: fbToken,
            success: (tokenData) {
              success = true;
              _loginContext.loggedIn(tokenData);
            },
            invalid: view.showInvalidMessages,
            error: view.showError)
        .whenComplete(() => {if (!success) view.setShowingViewState()});
  }

  Future<void> _signInServer(
      {@required String fbToken,
      Function success,
      Function invalid,
      Function error}) async {
    return await UserRepo.login(
        success: success, fbToken: fbToken, invalid: invalid, error: error);
  }

  void _onSignInError(Object e) {
    print(e);
    view.showError();
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
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

  void onSignInPressed() {
    if (view.isInFirebaseLoginProcess()) return;
    view.setInFirebaseLoginProcessState();
    _handleSignIn()
        .then(this._onSignInFinished)
        .catchError(this._onSignInError);
  }
}
