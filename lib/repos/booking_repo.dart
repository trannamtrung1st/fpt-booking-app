import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/apis/booking_api.dart';
import 'package:fptbooking_app/helpers/http_helper.dart';

class BookingRepo {
  static Future<void> getCalendar(
      {String fields = "info,room",
      String dateStr,
      String dateFormat = "dd/MM/yyyy",
      String dateType = "booked",
      Function(List<dynamic>) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await BookingApi.getCalendar(
        fields: fields,
        dateFormat: dateFormat,
        dateStr: dateStr,
        dateType: dateType);
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

  static Future<void> getOwner(
      {String fields = "info",
      String dateStr,
      String dateType = "booked",
      String groupBy,
      String search,
      int page,
      int limit,
      String status,
      String sorts,
      String dateFormat = "dd/MM/yyyy",
      Function(List<dynamic> list, int count) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await BookingApi.getOwner(
        fields: fields,
        groupBy: groupBy,
        status: status,
        page: page,
        limit: limit,
        loadAll: false,
        countTotal: true,
        dateFormat: dateFormat,
        search: search,
        dateStr: dateStr,
        dateType: dateType,
        sorts: sorts);
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

  static Future<void> getManagedRequest(
      {String fields = "info",
      String fromDateStr,
      String toDateStr,
      String dateType = "sent",
      int page,
      int limit,
      String status,
      String sorts,
      String dateFormat = "dd/MM/yyyy",
      Function(List<dynamic> list, int totalCount) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await BookingApi.getManagedRequest(
        fields: fields,
        page: page,
        limit: limit,
        loadAll: false,
        status: status,
        dateFormat: dateFormat,
        fromDateStr: fromDateStr,
        toDateStr: toDateStr,
        dateType: dateType,
        countTotal: true,
        sorts: sorts);
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

  static Future<void> getRoomBookings(
      {String fields = "info",
      String fromDateStr,
      String toDateStr,
      String roomCode,
      String dateType = "booked",
      int page,
      int limit,
      String status,
      String sorts,
      String dateFormat = "dd/MM/yyyy",
      Function(List<dynamic> list, int totalCount) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await BookingApi.getRoomBookings(
        fields: fields,
        page: page,
        limit: limit,
        roomCode: roomCode,
        loadAll: false,
        status: status,
        dateFormat: dateFormat,
        fromDateStr: fromDateStr,
        toDateStr: toDateStr,
        dateType: dateType,
        countTotal: true,
        sorts: sorts);
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
      {@required int id,
      String fields,
      String dateFormat,
      Function(dynamic) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await BookingApi.getDetail(
        id: id, dateFormat: dateFormat, fields: fields);
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

  static Future<void> updateBooking(
      {@required int id,
      dynamic model,
      Function() success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await BookingApi.updateBooking(id: id, model: model);
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

  static Future<void> feedbackBooking(
      {@required int id,
      dynamic model,
      Function() success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await BookingApi.feedbackBooking(id: id, model: model);
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

  static Future<void> abortBooking(
      {@required int id,
      dynamic model,
      Function() success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await BookingApi.abortBooking(id: id, model: model);
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

  static Future<void> changeApprovalStatusOfBooking(
      {@required int id,
      dynamic model,
      Function() success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response =
        await BookingApi.changeApprovalStatusOfBooking(id: id, model: model);
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
