import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/constants.dart';
import 'package:fptbooking_app/helpers/http_helper.dart';
import 'package:http/http.dart' as http;

class RoomTypeApi {
  static Future<http.Response> get({String fields, bool loadAll = true}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/room-types',
        {'fields': fields, 'load_all': loadAll?.toString()});
    var response = await http.get(uri, headers: HttpHelper.commonHeaders());
    return response;
  }
}
