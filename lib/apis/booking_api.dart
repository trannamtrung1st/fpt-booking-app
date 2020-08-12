import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/constants.dart';
import 'package:fptbooking_app/helpers/http_helper.dart';
import 'package:http/http.dart' as http;

class BookingApi {
  static Future<http.Response> updateBooking(
      {@required int id, dynamic model}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/bookings/$id');
    var response = await http.patch(uri,
        headers: HttpHelper.commonHeaders(hasBody: true),
        body: jsonEncode(model));
    return response;
  }

  static Future<http.Response> feedbackBooking(
      {@required int id, dynamic model}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/bookings/$id/feedback');
    var response = await http.post(uri,
        headers: HttpHelper.commonHeaders(hasBody: true),
        body: jsonEncode(model));
    return response;
  }

  static Future<http.Response> abortBooking(
      {@required int id, dynamic model}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/bookings/$id/cancel');
    var response = await http.post(uri,
        headers: HttpHelper.commonHeaders(hasBody: true),
        body: jsonEncode(model));
    return response;
  }

  static Future<http.Response> changeApprovalStatusOfBooking(
      {@required int id, dynamic model}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/bookings/$id/approval');
    var response = await http.post(uri,
        headers: HttpHelper.commonHeaders(hasBody: true),
        body: jsonEncode(model));
    return response;
  }

  static Future<http.Response> createBooking({@required dynamic model}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/bookings');
    var response = await http.post(uri,
        headers: HttpHelper.commonHeaders(hasBody: true),
        body: jsonEncode(model));
    return response;
  }

  static Future<http.Response> getCalendar(
      {String fields,
      String dateStr,
      String dateFormat,
      String dateType,
      bool loadAll = true}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/bookings/calendar', {
      'fields': fields,
      'date': dateStr,
      'date_type': dateType,
      'date_format': dateFormat,
    });
    var response = await http.get(uri, headers: HttpHelper.commonHeaders());
    return response;
  }

  static Future<http.Response> getOwner(
      {String fields,
      String dateStr,
      String dateType,
      String search,
      String sorts,
      String status,
      int page,
      int limit,
      bool countTotal,
      String groupBy,
      String dateFormat,
      bool loadAll = true}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/bookings', {
      'fields': fields,
      'group_by': groupBy,
      'search': search,
      'status': status,
      'date': dateStr,
      'date_type': dateType,
      'page': page?.toString(),
      'limit': limit?.toString(),
      'count_total': countTotal?.toString(),
      'sorts': sorts,
      'date_format': dateFormat,
      'load_all': loadAll?.toString()
    });
    var response = await http.get(uri, headers: HttpHelper.commonHeaders());
    return response;
  }

  static Future<http.Response> getManagedRequest(
      {String fields,
      String fromDateStr,
      String toDateStr,
      String dateType,
      int page,
      int limit,
      String status,
      String dateFormat,
      bool countTotal,
      String sorts,
      bool loadAll = true}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/bookings/managed', {
      'fields': fields,
      'status': status,
      'count_total': countTotal?.toString(),
      'page': page?.toString(),
      'limit': limit?.toString(),
      'from_date': fromDateStr,
      'to_date': toDateStr,
      'date_type': dateType,
      'sorts': sorts,
      'date_format': dateFormat,
      'load_all': loadAll?.toString()
    });
    var response = await http.get(uri, headers: HttpHelper.commonHeaders());
    return response;
  }

  static Future<http.Response> getRoomBookings(
      {String fields,
      String fromDateStr,
      String toDateStr,
      String dateType,
      String roomCode,
      int page,
      int limit,
      String status,
      String dateFormat,
      bool countTotal,
      String sorts,
      bool loadAll = true}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/bookings/room-bookings', {
      'fields': fields,
      'status': status,
      'count_total': countTotal?.toString(),
      'page': page?.toString(),
      'room_code': roomCode,
      'limit': limit?.toString(),
      'from_date': fromDateStr,
      'to_date': toDateStr,
      'date_type': dateType,
      'sorts': sorts,
      'date_format': dateFormat,
      'load_all': loadAll?.toString()
    });
    var response = await http.get(uri, headers: HttpHelper.commonHeaders());
    return response;
  }

  static Future<http.Response> getDetail(
      {@required int id, String dateFormat, String fields}) async {
    var uri = Uri.http(Constants.API_AUTH, '/api/bookings/$id',
        {'date_format': dateFormat, 'fields': fields});
    var response = await http.get(uri, headers: HttpHelper.commonHeaders());
    return response;
  }
}
