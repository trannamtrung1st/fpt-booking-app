import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/apis/user_api.dart';
import 'package:fptbooking_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepo {
  static Future<void> clearTokenData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(Constants.TOKEN_DATA_KEY);
  }

  static Future<dynamic> getTokenData() async {
    var prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> tokenData;
    var tokenDataStr = prefs.getString(Constants.TOKEN_DATA_KEY);
    if (tokenDataStr != null) {
      tokenData = jsonDecode(tokenDataStr);
    }
    return tokenData;
  }

  static Future<void> login(
      {@required String fbToken,
      Function(Map<String, dynamic> tokenData) success,
      Function(List<String> mess) invalid,
      Function() invalidEmail,
      Function error}) async {
    var response = await UserApi.login(fbToken: fbToken);
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(Constants.TOKEN_DATA_KEY, response.body);
      var tokenData = jsonDecode(response.body);
      if (success != null) success(tokenData);
      return;
    } else if (response.statusCode == 400) {
      var result = jsonDecode(response.body);
      print(result);
      var validationData = result["data"];
      var mess = <String>[];
      for (dynamic o in validationData) mess.add(o["message"] as String);
      if (invalid != null) invalid(mess);
      return;
    } else if (response.statusCode == 401) {
      if (invalidEmail != null) invalidEmail();
      return;
    }
    var result = jsonDecode(response.body);
    print(result);
    if (error != null) error();
  }
}
