import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/apis/room_api.dart';
import 'package:fptbooking_app/helpers/http_helper.dart';

class RoomRepo {
  static Future<void> getAvailableRooms(
      {String fields = "info,type",
      @required String dateStr,
      String dateFormat = "dd/MM/yyyy",
      @required String fromTime,
      @required String toTime,
      @required int numOfPeople,
      @required String roomTypeCode,
      int page,
      int limit,
      Function(List<dynamic> list, int count) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await RoomApi.get(
        fields: fields,
        dateFormat: dateFormat,
        dateStr: dateStr,
        fromTime: fromTime,
        page: page,
        limit: limit,
        loadAll: false,
        countTotal: true,
        numOfPeople: numOfPeople,
        roomTypeCode: roomTypeCode,
        empty: true,
        isAvailable: 1,
        toTime: toTime);
    if (response.isSuccess()) {
      print('Response body: ${response.body}');
      var result = jsonDecode(response.body);
      if (success != null)
        success(result["data"]["list"], result["data"]["count"]);
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

  static Future<void> getRooms(
      {String fields = "info,type",
      @required String search,
      int page,
      int limit,
      Function(List<dynamic> list, int count) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await RoomApi.get(
        fields: fields,
        search: search,
        loadAll: false,
        countTotal: true,
        page: page,
        limit: limit);
    if (response.isSuccess()) {
      print('Response body: ${response.body}');
      var result = jsonDecode(response.body);
      if (success != null)
        success(result["data"]["list"], result["data"]["count"]);
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
      {@required String code,
      Function(dynamic) success,
      bool hanging = true,
      bool checkerValid = false,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await RoomApi.getDetail(
        code: code,
        hanging: hanging,
        fields: checkerValid ? 'checker_valid' : null);
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

  static Future<void> cancelHangingRoom(
      {@required String code,
      Function() success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await RoomApi.changeHangingStatus(
        model: {"hanging": false, 'code': code});
    if (response.isSuccess()) {
      print("Success");
      if (success != null) success();
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

  static Future<void> releaseHangingRoom(
      {@required String userId,
      Function() success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await RoomApi.changeHangingStatus(
        model: {"release_hanging_user_id": userId});
    if (response.isSuccess()) {
      print("Success");
      if (success != null) success();
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

  static Future<void> checkRoomStatus(
      {@required String code,
      @required dynamic data,
      Function() success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await RoomApi.checkRoomStatus(code: code, model: data);
    if (response.isSuccess()) {
      print("Success");
      if (success != null) success();
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
