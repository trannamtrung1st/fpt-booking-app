import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/constants.dart';
import 'package:fptbooking_app/helpers/http_helper.dart';
import 'package:http/http.dart' as http;

class UserApi {
  static Future<http.Response> login({@required String fbToken}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/users/login');
    var response = await http.post(uri,
        headers: HttpHelper.commonHeaders(hasBody: true),
        body: jsonEncode({
          "grant_type": "firebase_token",
          "firebase_token": fbToken,
          "scope": "roles"
        }));
    return response;
  }
}
