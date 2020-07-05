import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/constants.dart';
import 'package:fptbooking_app/helpers/http_helper.dart';
import 'package:http/http.dart' as http;

class RoomApi {
  static Future<http.Response> get({
    String fields,
    String search,
    String dateStr,
    String dateFormat,
    String fromTime,
    String toTime,
    int numOfPeople,
    String roomTypeCode,
  }) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/rooms', {
      'search': search,
      'fields': fields,
      'date_str': dateStr,
      'date_format': dateFormat,
      'from_time': fromTime,
      'to_time': toTime,
      'num_of_people': numOfPeople.toString(),
      'room_type': roomTypeCode,
    });
    var response = await http.get(uri, headers: HttpHelper.commonHeaders());
    return response;
  }

  static Future<http.Response> getDetail(
      {@required String code}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/rooms/$code');
    var response = await http.get(uri, headers: HttpHelper.commonHeaders());
    return response;
  }
}
