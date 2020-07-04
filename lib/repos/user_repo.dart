import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fptbooking_app/apis/user_api.dart';
import 'package:fptbooking_app/constants.dart';
import 'package:fptbooking_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepo {
  static Future<bool> login(
      {@required String fbToken,
      Function success,
      Function invalid,
      Function error}) async {
    var response = await UserApi.login(fbToken);
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(Constants.TOKEN_DATA_KEY, response.body);
      var tokenData = jsonDecode(response.body);
      if (success != null) success(tokenData);
      return true;
    } else if (response.statusCode != 500) {
      var result = jsonDecode(response.body);
      print(result);
      var validationData = result["data"];
      var mess = <String>[];
      for (dynamic o in validationData) mess.add(o["message"] as String);
      if (invalid != null) invalid(mess);
      return false;
    }
    var result = jsonDecode(response.body);
    print(result);
    if (error != null) error();
    return false;
  }
}
