import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/apis/booking_api.dart';

class BookingRepo {
  static Future<void> get(
      {String fields = "info",
      String dateStr,
      String dateFormat = "dd/MM/yyyy",
      Function(List<dynamic>) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await BookingApi.get(
        fields: fields, dateFormat: dateFormat, dateStr: dateStr);
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      var result = jsonDecode(response.body);
      if (success != null) success(result["data"]["list"]);
      return;
    } else if (response.statusCode == 400) {
      var result = jsonDecode(response.body);
      print(result);
      var validationData = result["data"]["results"];
      var mess = <String>[];
      for (dynamic o in validationData) mess.add(o["message"] as String);
      if (invalid != null) invalid(mess);
      return;
    }
    var result = jsonDecode(response.body);
    print(result);
    if (error != null) error();
  }

  static Future<void> getManagedRequest(
      {String fields = "info",
      String fromDateStr,
      String toDateStr,
      String sorts,
      String dateFormat = "dd/MM/yyyy",
      Function(List<dynamic>) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await BookingApi.getManagedRequest(
        fields: fields,
        dateFormat: dateFormat,
        fromDateStr: fromDateStr,
        toDateStr: toDateStr,
        sorts: sorts);
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      var result = jsonDecode(response.body);
      if (success != null) success(result["data"]["list"]);
      return;
    } else if (response.statusCode == 400) {
      var result = jsonDecode(response.body);
      print(result);
      var validationData = result["data"]["results"];
      var mess = <String>[];
      for (dynamic o in validationData) mess.add(o["message"] as String);
      if (invalid != null) invalid(mess);
      return;
    }
    var result = jsonDecode(response.body);
    print(result);
    if (error != null) error();
  }

  static Future<void> getDetail(
      {@required int id,
      Function(dynamic) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await BookingApi.getDetail(id: id);
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      var result = jsonDecode(response.body);
      if (success != null) success(result["data"]["single"]);
      return;
    } else if (response.statusCode == 400) {
      var result = jsonDecode(response.body);
      print(result);
      var validationData = result["data"]["results"];
      var mess = <String>[];
      for (dynamic o in validationData) mess.add(o["message"] as String);
      if (invalid != null) invalid(mess);
      return;
    }
    var result = jsonDecode(response.body);
    print(result);
    if (error != null) error();
  }
}
