import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fptbooking_app/constants.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/widgets/tab_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LoginContext _loginContext;

  @override
  Widget build(BuildContext context) {
    _loginContext = Provider.of<LoginContext>(context, listen: false);
    return TabView(
      child: Center(
        child: RaisedButton(
          onPressed: () async {
            await _googleSignIn.signOut();
            await _auth.signOut();
            final prefs = await SharedPreferences.getInstance();
            prefs.remove(Constants.TOKEN_DATA_KEY);
            _loginContext.signOut();
          },
          child: Text("Logout"),
        ),
      ),
    );
  }
}
