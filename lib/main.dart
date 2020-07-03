import 'package:flutter/material.dart';
import 'package:fptbooking_app/constants.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/views/login_view.dart';
import 'package:fptbooking_app/views/main_view.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginContext()),
      ],
      child: _materialApp(),
    ),
  );
}

Widget _materialApp() {
  return MaterialApp(
    title: 'FPT Booking', // used by the OS task switcher
    home: App(),
  );
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  static const int PRE_PROCESSING = 1;
  static const int SHOWING_VIEW = 2;
  int _state = PRE_PROCESSING;
  LoginContext _loginContext;

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginContext>(
      builder: (context, loginContext, child) {
        _loginContext = loginContext;
        if (loginContext.isLoggedIn()) {
          _handleLoggedIn(context);
          return _buildLoggedInWidget(context);
        }
        if (_isPreProcessing()) {
          _handlePreProcessing(context);
          return _buildPreProcessingWidget(context);
        }
        _handleNotLoggedIn(context);
        return _buildNotLoggedInWidget(context);
      },
    );
  }

  //isPreProcessing
  bool _isPreProcessing() => _state == PRE_PROCESSING;

  void _handlePreProcessing(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      var tokenDataStr = prefs.getString(Constants.TOKEN_DATA_KEY);
      if (tokenDataStr != null) {
        _loginContext.loggedIn();
        return;
      }
      setState(() {
        _state = SHOWING_VIEW;
      });
    });
  }

  Widget _buildPreProcessingWidget(BuildContext context) {
    return LoadingModal(
      isLoading: true,
      child: Container(
        color: Colors.white,
      ),
    );
  }

  //isLoggedIn
  void _handleLoggedIn(BuildContext context) {}

  Widget _buildLoggedInWidget(BuildContext context) {
    return MainView();
  }

  //isNotLoggedIn
  void _handleNotLoggedIn(BuildContext context) {}

  Widget _buildNotLoggedInWidget(BuildContext context) {
    return LoginView();
  }
}
