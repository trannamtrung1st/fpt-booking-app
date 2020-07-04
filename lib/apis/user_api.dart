import 'dart:convert';

import 'package:fptbooking_app/constants.dart';
import 'package:fptbooking_app/helpers/http_helper.dart';
import 'package:http/http.dart' as http;

class UserApi {
  static Future<http.Response> login(String fbToken) async {
    var url = Constants.API_URL + '/api/users/login';
    var response = await http.post(url,
        headers: HttpHelper.commonHeaders(hasBody: true),
        body: jsonEncode({
          "grant_type": "firebase_token",
          "firebase_token": fbToken,
          "scope": "roles"
        }));
    return response;
  }
}
