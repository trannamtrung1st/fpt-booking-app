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
    bool empty,
    int isAvailable,
    bool loadAll = true,
    String roomTypeCode,
  }) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/rooms', {
      'search': search,
      'fields': fields,
      'date': dateStr,
      'date_format': dateFormat,
      'from_time': fromTime,
      'to_time': toTime,
      'empty': empty?.toString(),
      'is_available': isAvailable?.toString(),
      'num_of_people': numOfPeople?.toString(),
      'room_type': roomTypeCode,
      'load_all': loadAll?.toString()
    });
    var response = await http.get(uri, headers: HttpHelper.commonHeaders());
    return response;
  }

  static Future<http.Response> getDetail(
      {@required String code, bool hanging, String fields}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/rooms/$code',
        {'hanging': hanging?.toString(), 'fields': fields});
    var response = await http.get(uri, headers: HttpHelper.commonHeaders());
    return response;
  }

  static Future<http.Response> changeHangingStatus(
      {@required dynamic model}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/rooms/hanging');
    var response = await http.put(uri,
        headers: HttpHelper.commonHeaders(hasBody: true),
        body: jsonEncode(model));
    return response;
  }

  static Future<http.Response> checkRoomStatus(
      {@required String code, dynamic model}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/rooms/$code/status');
    var response = await http.patch(uri,
        headers: HttpHelper.commonHeaders(hasBody: true),
        body: jsonEncode(model));
    return response;
  }
}
