import 'dart:io';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fptbooking_app/constants.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/contexts/page_context.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/noti_helper.dart';
import 'package:fptbooking_app/navigations/main_nav.dart';
import 'package:fptbooking_app/repos/room_repo.dart';
import 'package:fptbooking_app/repos/room_type_repo.dart';
import 'package:fptbooking_app/repos/user_repo.dart';
import 'package:fptbooking_app/views/login_view.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:provider/provider.dart';

//Update launcher image
//flutter pub pub run flutter_launcher_icons:main

Future<dynamic> handleBackgroundFirebaseMessage(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
//    final dynamic data = message['data'];
  }
  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    NotiHelper.show(title: notification["title"], body: notification["body"]);
  }
  return null;
}

void main() async {
  //static init
  MainNav.init();

  //run app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginContext()),
        ChangeNotifierProvider(create: (context) => PageContext()),
      ],
      child: _materialApp(),
    ),
  );
}

Widget _materialApp() {
  return MaterialApp(
    title: 'FPT Booking', // used by the OS task switcher
    home: App(),
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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static const int PREPARE = 0;
  static const int PRE_PROCESSING = 1;
  static const int SHOWING_VIEW = 2;
  int _state = PREPARE;
  LoginContext loginContext;
  _AppPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = _AppPresenter(view: this);
  }

  Future<void> showInvalidMessages(List<String> mess) {
    return DialogHelper.showMessage(
        context: context, title: "Sorry", contents: mess);
  }

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    if (_isPrepare()) {
      _presenter.prepareData();
      return LoadingModal(
        isLoading: true,
        child: Material(
          child: Container(),
        ),
      );
    }

    NotiHelper.init(_presenter.onDidReceiveLocalNotification,
        _presenter.onSelectNotification);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final dynamic notification = message['notification'];
        NotiHelper.show(
            title: notification["title"], body: notification["body"]);
      },
      onBackgroundMessage: handleBackgroundFirebaseMessage,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        final dynamic notification = message['notification'];
        NotiHelper.show(
            title: notification["title"], body: notification["body"]);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        final dynamic notification = message['notification'];
        NotiHelper.show(
            title: notification["title"], body: notification["body"]);
      },
    );

    return Consumer<LoginContext>(
      builder: (context, loginContext, child) {
        this.loginContext = loginContext;
        _presenter = _AppPresenter(view: this);
        if (loginContext.isLoggedIn()) {
          _presenter.releaseHangingRoom();
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

  //isPrepare
  bool _isPrepare() => _state == PREPARE;

  //isPreProcessing
  bool _isPreProcessing() => _state == PRE_PROCESSING;

  void setPreProcessingState() => setState(() {
        _state = PRE_PROCESSING;
      });

  //isShowingView
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

  void releaseHangingRoom() {
    RoomRepo.releaseHangingRoom(userId: _loginContext.tokenData["user_id"]);
  }

  void prepareData() {
    //prepare data
    var finalSuccess = false;
    var checker = DataConnectionChecker();
    checker.addresses = [
      AddressCheckOptions(InternetAddress(Constants.API_AUTH.split(':')[0]),
          port: int.parse(Constants.API_AUTH.split(':')[1]),
          timeout: DataConnectionChecker.DEFAULT_TIMEOUT)
    ];
    checker.hasConnection.then((success) {
      if (success == true) {
        print('<3<3<3');
        return RoomTypeRepo.getAll(success: (list) {
          RoomTypeRepo.saveToMemoryStorage(list);
          finalSuccess = true;
        }).catchError((e) => {print(e)});
      } else {
        print('No internet :( Reason:');
        print(DataConnectionChecker().lastTryResults);
      }
      return null;
    }).whenComplete(() {
      if (!finalSuccess) {
        view.showInvalidMessages(["Internet connection required"]).then(
            (value) {
          exit(0);
        });
      } else
        view.setPreProcessingState();
    });
  }

  void handlePreProcessing(BuildContext context) {
    UserRepo.getTokenData().then((tokenData) {
      if (tokenData != null) {
        _loginContext.loggedIn(tokenData);
      }
      view.setShowingViewState();
    });
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    print("$id - $title - $body - $payload");
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      print('notification payload: ' + payload);
    }
  }
}
