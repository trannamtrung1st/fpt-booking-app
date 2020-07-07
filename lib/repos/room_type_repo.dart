import 'dart:convert';
import 'package:fptbooking_app/apis/room_type_api.dart';
import 'package:fptbooking_app/storages/memory_storage.dart';

class RoomTypeRepo {
  static Future<void> getAll(
      {String fields = "info,services",
      Function(List<dynamic> list) success,
      Function(List<String> mess) invalid,
      Function error}) async {
    var response = await RoomTypeApi.get(fields: fields);
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

  static void saveToMemoryStorage(List<dynamic> roomTypes) {
    MemoryStorage.roomTypesMap =
        Map.fromIterable(roomTypes, key: (e) => e["code"], value: (e) => e);
  }
}
