import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/apis/room_api.dart';

class RoomRepo {
  static Future<void> getAvailableRooms(
      {String fields = "info,type",
      @required String dateStr,
      String dateFormat = "dd/MM/yyyy",
      @required String fromTime,
      @required String toTime,
      @required int numOfPeople,
      @required String roomTypeCode,
      Function(List<dynamic>) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await RoomApi.get(
        fields: fields,
        dateFormat: dateFormat,
        dateStr: dateStr,
        fromTime: fromTime,
        numOfPeople: numOfPeople,
        roomTypeCode: roomTypeCode,
        empty: true,
        isAvailable: true,
        toTime: toTime);
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

  static Future<void> getRooms(
      {String fields = "info,type",
      @required String search,
      Function(List<dynamic>) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await RoomApi.get(fields: fields, search: search);
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
      {@required String code,
      Function(dynamic) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await RoomApi.getDetail(code: code);
    if (response.statusCode == 200) {
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
    var result = jsonDecode(response.body);
    print(result);
    if (error != null) error();
  }
}
