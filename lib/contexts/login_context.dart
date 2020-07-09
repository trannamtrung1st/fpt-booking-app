import 'package:flutter/foundation.dart';
import 'package:fptbooking_app/constants.dart';

class LoginContext extends ChangeNotifier {
  static const int NOT_LOGGED_IN = 1;
  static const int LOGGED_IN = 2;
  static String accessToken;
  Map<String, dynamic> tokenData;
  int _state = NOT_LOGGED_IN;
  List<dynamic> roles;

  bool isLoggedIn() => _state == LOGGED_IN;

  bool isNotLoggedIn() => _state == NOT_LOGGED_IN;

  void loggedIn(Map<String, dynamic> tokenData) {
    LoginContext.accessToken = tokenData["access_token"] as String;
    this.tokenData = tokenData;
    this.roles = tokenData["roles"] as List<dynamic>;
    _state = LOGGED_IN;
    notifyListeners();
  }

  void signOut() {
    LoginContext.accessToken = null;
    this.tokenData = null;
    this.roles = null;
    _state = NOT_LOGGED_IN;
    notifyListeners();
  }

  bool isManager() {
    return roles.contains(Constants.ROLE_MANAGER);
  }

  bool isViewOnlyUser() {
    return tokenData["is_view_only_user"] == true;
  }

  bool isRoomChecker() {
    return roles.contains(Constants.ROLE_ROOM_CHECKER);
  }
}
