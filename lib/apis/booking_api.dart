import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/constants.dart';
import 'package:fptbooking_app/helpers/http_helper.dart';
import 'package:http/http.dart' as http;

class BookingApi {
  static Future<http.Response> get(
      {String fields, String dateStr, String dateFormat}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/bookings',
        {'fields': fields, 'date': dateStr, 'date_format': dateFormat});
    var response = await http.get(uri, headers: HttpHelper.commonHeaders());
    return response;
  }

  static Future<http.Response> getManagedRequest(
      {String fields,
      String fromDateStr,
      String toDateStr,
      String dateFormat,
      String sorts}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/bookings/managed', {
      'fields': fields,
      'from_date': fromDateStr,
      'to_date': toDateStr,
      'sorts': sorts,
      'date_format': dateFormat
    });
    var response = await http.get(uri, headers: HttpHelper.commonHeaders());
    return response;
  }

  static Future<http.Response> getDetail({@required int id}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/bookings/$id');
    var response = await http.get(uri, headers: HttpHelper.commonHeaders());
    return response;
  }
}
