import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fptbooking_app/widgets/app_card.dart';

class SingleRoomCard extends StatelessWidget {
  final dynamic room;
  final Function(dynamic val) onRoomPressed;
  final bool showStatus;

  SingleRoomCard({this.room, this.onRoomPressed, this.showStatus = true});

  @override
  Widget build(BuildContext context) {
    var iconWidgets = <Widget>[
      Container(
        child: Icon(
          Icons.school,
          size: 45,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(7),
        margin: EdgeInsets.only(bottom: 7),
        decoration: BoxDecoration(
            color: Colors.deepOrangeAccent, shape: BoxShape.circle),
      ),
    ];
    if (showStatus)
      iconWidgets.add(Text(
        "EMPTY",
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      ));

    return AppCard(
      onTap: () => onRoomPressed(room),
      margin: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(right: 20),
                child: Column(
                  children: iconWidgets,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: room["code"],
                      style: TextStyle(fontSize: 17, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: "   " + room["room_type"]["name"],
                            style:
                                TextStyle(color: Colors.orange, fontSize: 14)),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Icon(
                        Icons.fullscreen,
                        color: Colors.grey,
                        size: 22,
                      ),
                      Text(
                        " " + room["area_size"].toString() + " m2",
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Icon(
                        Icons.people,
                        color: Colors.grey,
                        size: 22,
                      ),
                      Text(
                        " At most " + room["people_capacity"].toString(),
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
