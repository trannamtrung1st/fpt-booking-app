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
  final Function(dynamic room) onRoomPressed;

  AvailableRoomList(
      {this.selectedDate,
      this.fromTime,
      this.toTime,
      this.rooms,
      this.onRoomPressed,
      Key key})
      : super(key: key);

  @override
  _AvailableRoomListState createState() => _AvailableRoomListState(
      fromTime: fromTime,
      toTime: toTime,
      onRoomPressed: onRoomPressed,
      rooms: rooms,
      selectedDate: selectedDate);
}

class _AvailableRoomListState extends State<AvailableRoomList> {
  DateTime selectedDate;
  String fromTime;
  String toTime;
  List<dynamic> rooms;
  Function(dynamic room) onRoomPressed;

  _AvailableRoomListState(
      {this.selectedDate,
      this.fromTime,
      this.toTime,
      this.rooms,
      this.onRoomPressed});

  @override
  Widget build(BuildContext context) {
    var dateStr = IntlHelper.format(selectedDate);
    var cardWidgets = <Widget>[
      Text("Available rooms on $dateStr from $fromTime - $toTime")
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
        onRoomPressed: (val) => onRoomPressed(val),
      ));
    }
    return card;
  }
}
