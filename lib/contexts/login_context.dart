import 'package:flutter/foundation.dart';

class LoginContext extends ChangeNotifier {
  static const int NOT_LOGGED_IN = 1;
  static const int LOGGED_IN = 2;
  int _state = NOT_LOGGED_IN;

  bool isLoggedIn() => _state == LOGGED_IN;

  bool isNotLoggedIn() => _state == NOT_LOGGED_IN;

  void loggedIn() {
    _state = LOGGED_IN;
    notifyListeners();
  }

  void signOut() {
    _state = NOT_LOGGED_IN;
    notifyListeners();
  }
}
