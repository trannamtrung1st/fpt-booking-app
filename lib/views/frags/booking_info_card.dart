import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';

class BookingInfoCard extends StatelessWidget {
  final dynamic booking;
  final Function(dynamic val) onBookingPressed;
  final bool showStatus;
  final List<Widget> details;
  final EdgeInsets margin;

  BookingInfoCard(
      {this.booking,
      this.onBookingPressed,
      this.showStatus = true,
      this.details,
      this.margin});

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    return AppCard(
      onTap: onBookingPressed != null ? () => onBookingPressed(booking) : null,
      margin: margin ?? EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            booking["code"],
            style: TextStyle(color: Colors.blue),
          ),
          SimpleInfo(
            labelText: "Room:",
            containerMargin: EdgeInsets.only(top: 7, bottom: 7),
            child: Text(booking["room"]["code"]),
            isHorizontal: true,
          ),
          SimpleInfo(
            labelText: "Booked date:",
            child: Text(booking["booked_date"]["display"]),
            isHorizontal: true,
          ),
          SimpleInfo(
            labelText: "Status:",
            child: ViewHelper.getTextByBookingStatus(status: booking["status"]),
            isHorizontal: true,
          )
        ],
      ),
    );
  }
}
