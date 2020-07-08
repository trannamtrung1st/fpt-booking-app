import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/repos/user_repo.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  SettingsView({key}) : super(key: key);

  static void Function() needRefresh = () {};

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with AutomaticKeepAliveClientMixin {
  LoginContext loginContext;

  static const int SHOWING_VIEW = 1;
  int _state = SHOWING_VIEW;

  _SettingsViewPresenter _presenter;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SettingsView.needRefresh = () {
      _keepAlive = false;
      this.updateKeepAlive();
    };
  }

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    super.build(context);
    if (_keepAlive) {
      _keepAlive = true;
      updateKeepAlive();
    }
    loginContext = Provider.of<LoginContext>(context, listen: false);
    _presenter = _SettingsViewPresenter(view: this);
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  Widget _buildShowingViewWidget(BuildContext context) {
    var imgSrc = loginContext.tokenData["photo_url"];
    return ListView(children: <Widget>[
      AppCard(
        margin: EdgeInsets.only(bottom: 7),
        child: Column(
          children: <Widget>[
            Container(
              child: imgSrc == null
                  ? Image.asset(
                      "assets/user.png",
                      width: 100,
                    )
                  : Image.network(
                      imgSrc,
                      width: 100,
                    ),
              margin: EdgeInsets.only(bottom: 10),
            ),
            Text(loginContext.tokenData["email"] ?? "Anonymous")
          ],
        ),
      ),
      AppCard(
          margin: EdgeInsets.only(bottom: 7),
          child: Row(children: <Widget>[
            Icon(Icons.notifications),
            Text("  Notification"),
            Spacer(),
            Switch(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) {},
              value: true,
            )
          ])),
      AppCard(
          margin: EdgeInsets.only(bottom: 7),
          onTap: _presenter.onLogOutPressed,
          child: Row(
              children: <Widget>[Icon(Icons.exit_to_app), Text("  Logout")]))
    ]);
  }

  void showInvalidMessages(List<String> mess) {
    DialogHelper.showMessage(context: context, title: "Sorry", contents: mess);
  }

  void showError() {
    DialogHelper.showUnknownError(context: this.context);
  }

  bool _keepAlive = true;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => _keepAlive;
}

class _SettingsViewPresenter {
  _SettingsViewState view;
  LoginContext _loginContext;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _SettingsViewPresenter({this.view}) {
    _loginContext = view.loginContext;
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void onLogOutPressed() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    var tokenData = _loginContext.tokenData;
    await UserRepo.clearTokenData();
    await _firebaseMessaging.unsubscribeFromTopic(tokenData["user_id"]);
    _loginContext.signOut();
  }
}
