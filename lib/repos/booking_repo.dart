import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/apis/booking_api.dart';
import 'package:fptbooking_app/helpers/http_helper.dart';

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
    if (response.isSuccess()) {
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
    print(response.body);
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
    if (response.isSuccess()) {
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
    print(response.body);
    if (error != null) error();
  }

  static Future<void> getDetail(
      {@required int id,
      String dateFormat,
      Function(dynamic) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await BookingApi.getDetail(id: id, dateFormat: dateFormat);
    if (response.isSuccess()) {
      print('Response body: ${response.body}');
      var result = jsonDecode(response.body);
      if (success != null) success(result["data"]);
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
    print(response.body);
    if (error != null) error();
  }

  static Future<void> createBooking(
      {@required dynamic data,
      Function(int id) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await BookingApi.createBooking(model: data);
    if (response.isSuccess()) {
      print('Response body: ${response.body}');
      var result = jsonDecode(response.body);
      if (success != null) success(result["data"]);
      return;
    } else if (response.statusCode == 400) {
      print("Invalid");
      var result = jsonDecode(response.body);
      print(result);
      var validationData = result["data"]["results"];
      var mess = <String>[];
      for (dynamic o in validationData) mess.add(o["message"] as String);
      if (invalid != null) invalid(mess);
      return;
    }
    print(response.body);
    if (error != null) error();
  }
}
