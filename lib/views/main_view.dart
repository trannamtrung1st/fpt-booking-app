import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fptbooking_app/constants.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/tab_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainView extends StatefulWidget {
  MainView({key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  LoginContext loginContext;

  static const int SHOWING_VIEW = 1;
  int _state = SHOWING_VIEW;

  _MainViewPresenter _presenter;

  @override
  Widget build(BuildContext context) {
    loginContext = Provider.of<LoginContext>(context);
    _presenter = _MainViewPresenter(view: this);
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  Widget _buildShowingViewWidget(BuildContext context) {
    return LoadingModal(
        isLoading: false,
        child: TabView(
          child: Center(
            child: RaisedButton(
              onPressed: _presenter.onLogOutPressed,
              child: Text("Logout"),
            ),
          ),
        ));
  }

  void showInvalidMessages(List<String> mess) {
    DialogHelper.showMessage(context: context, title: "Sorry", contents: mess);
  }

  void showError() {
    DialogHelper.showUnknownError(context: this.context);
  }
}

class _MainViewPresenter {
  _MainViewState view;
  LoginContext _loginContext;

  _MainViewPresenter({this.view}) {
    _loginContext = view.loginContext;
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void onLogOutPressed() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(Constants.TOKEN_DATA_KEY);
    _loginContext.signOut();
  }
}
