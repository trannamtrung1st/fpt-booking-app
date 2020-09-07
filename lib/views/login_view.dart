import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/repos/user_repo.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  LoginView({key}) : super(key: key);

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
    //print("build ${this.runtimeType}");
    loginContext = Provider.of<LoginContext>(context, listen: false);
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
      child: new OrientationBuilder(
        builder: (context, orientation) => orientation == Orientation.portrait
            ? _loginViewVertical()
            : _loginViewHorizontal(),
      ),
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
      child: new OrientationBuilder(
        builder: (context, orientation) => orientation == Orientation.portrait
            ? _loginViewVertical()
            : _loginViewHorizontal(),
      ),
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
      splashColor: "#CCCCCC".toColor(),
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

  Widget _loginViewVertical() {
    return Material(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
//                colorFilter: new ColorFilter.mode(
//                    Colors.white.withOpacity(0.5), BlendMode.dstATop),
                image: new ExactAssetImage("assets/app-bg.jpg"))),
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _logo(),
            Container(
                height: 270,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.3)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Image.asset("assets/fpt-logo.png"),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: _signInButton(),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget _loginViewHorizontal() {
    return Material(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                colorFilter: new ColorFilter.mode(
                    Colors.white.withOpacity(0.75), BlendMode.dstATop),
                image: new ExactAssetImage("assets/login-bg.jpg"))),
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _logo(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Image.asset("assets/fpt-logo.png"),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: _signInButton(),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Stroked text as border.
          Text(
            "FPT BOOKING",
            style: TextStyle(
              letterSpacing: 5,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              shadows: <Shadow>[
                Shadow(blurRadius: 20, color: Colors.orange),
                Shadow(blurRadius: 20, color: Colors.orange)
              ],
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = Colors.orange,
            ),
          ),
          // Solid text as fill.
          Text(
            'FPT BOOKING',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 5,
              fontSize: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginViewPresenter {
  _LoginViewState view;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LoginContext _loginContext;

  _LoginViewPresenter({this.view}) {
    _loginContext = view.loginContext;
  }

  void _onSignInFinished(User user) async {
    if (user == null) return;
    //IdTokenResult fbTokenResult = await user.getIdToken(refresh: true);
    IdTokenResult fbTokenResult = await user.getIdTokenResult(true);
    String fbToken = fbTokenResult.token;
    print(fbToken);
    var success = false;
    _signInServer(
            fbToken: fbToken,
            success: (tokenData) {
              _firebaseMessaging
                  .subscribeToTopic(tokenData["user_id"])
                  .catchError((e) => _loginError(err: e))
                  .then((value) {
                success = true;
                _loginContext.loggedIn(tokenData);
              }).catchError((e) => _loginError(err: e));
            },
            invalid: view.showInvalidMessages,
            error: _loginError)
        .whenComplete(() {
      if (!success) view.setShowingViewState();
    });
  }

  Future<void> _loginError({Object err}) async {
    print(err);
    view.showError();
    await _googleSignIn.signOut();
    await _auth.signOut();
    var tokenData = _loginContext.tokenData ?? (await UserRepo.getTokenData());
    if (tokenData != null) {
      await UserRepo.clearTokenData();
      await _firebaseMessaging.unsubscribeFromTopic(tokenData["user_id"]);
      _loginContext.signOut();
    }
  }

  Future<void> _signInServer(
      {@required String fbToken,
      Function success,
      Function invalid,
      Function error}) async {
    return await UserRepo.login(
        invalidEmail: _handleInvalidEmail,
        success: success,
        fbToken: fbToken,
        invalid: invalid,
        error: error);
  }

  Future<void> _handleInvalidEmail() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    view.showInvalidMessages(["Only @fpt.edu.vn is allowed"]);
  }

  Future<User> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      view.setShowingViewState();
      return null;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  void onSignInPressed() {
    if (view.isInFirebaseLoginProcess()) return;
    view.setInFirebaseLoginProcessState();
    _handleSignIn()
        .then(this._onSignInFinished)
        .catchError((e) => this._loginError(err: e));
  }
}
