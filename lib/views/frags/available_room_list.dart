import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/views/frags/room_info_card.dart';
import 'package:fptbooking_app/widgets/app_card.dart';

class AvailableRoomList extends StatefulWidget {
  final DateTime selectedDate;
  final String fromTime;
  final String toTime;
  final List<dynamic> rooms;
  final int numOfPeople;
  final Function(dynamic room, DateTime date, String fromTime, String toTime,
      int numOfPeople) onRoomPressed;
  final Widget paging;

  AvailableRoomList(
      {this.selectedDate,
      this.paging,
      this.fromTime,
      this.toTime,
      this.rooms,
      this.numOfPeople,
      this.onRoomPressed,
      Key key})
      : super(key: key);

  @override
  _AvailableRoomListState createState() => _AvailableRoomListState(
      fromTime: fromTime,
      paging: paging,
      toTime: toTime,
      onRoomPressed: onRoomPressed,
      rooms: rooms,
      numOfPeople: numOfPeople,
      selectedDate: selectedDate);
}

class _AvailableRoomListState extends State<AvailableRoomList> {
  DateTime selectedDate;
  String fromTime;
  String toTime;
  List<dynamic> rooms;
  int numOfPeople;
  Function(dynamic room, DateTime date, String fromTime, String toTime,
      int numOfPeople) onRoomPressed;
  Widget paging;

  _AvailableRoomListState(
      {this.selectedDate,
      this.fromTime,
      this.paging,
      this.toTime,
      this.numOfPeople,
      this.rooms,
      this.onRoomPressed});

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    var dateStr = IntlHelper.format(selectedDate);
    var cardWidgets = <Widget>[
      Text((rooms.length > 0 ? "Available" : "No") +
          " rooms on $dateStr from $fromTime - $toTime")
    ];
    var card = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cardWidgets,
      ),
    );

    for (dynamic o in rooms) {
      cardWidgets.add(RoomInfoCard(
        room: o,
        onRoomPressed: (val) =>
            onRoomPressed(val, selectedDate, fromTime, toTime, numOfPeople),
      ));
    }
    if (rooms.length > 0) cardWidgets.add(paging);
    return card;
  }
}
