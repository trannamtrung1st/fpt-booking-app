import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fptbooking_app/constants.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/navigations/main_nav.dart';
import 'package:fptbooking_app/repos/room_type_repo.dart';
import 'package:fptbooking_app/storages/memory_storage.dart';
import 'package:fptbooking_app/views/login_view.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  //prepare
  var success = false;
  await RoomTypeRepo.getAll(success: (list) {
    MemoryStorage.roomTypes = list;
    success = true;
  }).catchError((e) => {print(e)});
  if (!success) {
//    SystemNavigator.pop();
    exit(0);
    return;
  }

  //static init
  MainNav.init();

  //run app
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
    home: SafeArea(
      child: App(),
    ),
    theme: ThemeData(
      //for scroll-overflowed color
      accentColor: Colors.orange,
    ),
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
  LoginContext loginContext;
  _AppPresenter _presenter;

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginContext>(
      builder: (context, loginContext, child) {
        this.loginContext = loginContext;
        _presenter = _AppPresenter(view: this);
        if (loginContext.isLoggedIn()) {
          return _buildLoggedInWidget(context);
        }
        if (_isPreProcessing()) {
          _presenter.handlePreProcessing(context);
          return _buildPreProcessingWidget(context);
        }
        return _buildNotLoggedInWidget(context);
      },
    );
  }

  //isPreProcessing
  bool _isPreProcessing() => _state == PRE_PROCESSING;

  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  Widget _buildPreProcessingWidget(BuildContext context) {
    return LoadingModal(
      isLoading: true,
      child: Container(
        color: Colors.white,
      ),
    );
  }

  //isLoggedIn
  Widget _buildLoggedInWidget(BuildContext context) {
    return MainNav();
  }

  //isNotLoggedIn
  Widget _buildNotLoggedInWidget(BuildContext context) {
    return LoginView();
  }
}

class _AppPresenter {
  _AppState view;
  LoginContext _loginContext;

  _AppPresenter({this.view}) {
    _loginContext = view.loginContext;
  }

  void handlePreProcessing(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      var tokenDataStr = prefs.getString(Constants.TOKEN_DATA_KEY);
      if (tokenDataStr != null) {
        var tokenData = jsonDecode(tokenDataStr);
        _loginContext.loggedIn(tokenData);
        return;
      }
      view.setShowingViewState();
    });
  }
}
