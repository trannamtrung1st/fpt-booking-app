import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/widgets/app_table.dart';
import 'package:intl/intl.dart';

class ApprovalRequestTable extends StatefulWidget {
  final List<dynamic> bookings;
  final Function(dynamic val) onRowTap;
  final String status;
  final DateTime fromDate;
  final DateTime toDate;

  ApprovalRequestTable(
      {this.bookings, this.onRowTap, this.status, this.fromDate, this.toDate});

  @override
  _ApprovalRequestTableState createState() => _ApprovalRequestTableState(
      bookings: bookings,
      onRowTap: onRowTap,
      status: status,
      fromDate: fromDate,
      toDate: toDate);
}

class _ApprovalRequestTableState extends State<ApprovalRequestTable> {
  List<dynamic> bookings;
  Function(dynamic val) onRowTap;
  final String status;
  final DateTime fromDate;
  final DateTime toDate;

  _ApprovalRequestTableState(
      {this.bookings, this.onRowTap, this.status, this.fromDate, this.toDate});

  @override
  Widget build(BuildContext context) {
    var rows = <AppTableRow>[
      AppTableRow(data: <dynamic>["Date", "Time", "Room", "Status"]),
    ];
    if (bookings != null)
      for (dynamic o in bookings) {
        var date = o["booked_date"];
        var time = o["from_time"] + " - " + o["to_time"];
        var room = o["room"]["code"];
        var status = o["status"] ?? "";
        var statusText = ViewHelper.getTextByBookingStatus(status: status);
        rows.add(AppTableRow(
            data: <dynamic>[date, time, room, statusText],
            onTap: () => this.onRowTap(o)));
      }
    var dateStr =
        IntlHelper.format(fromDate) + " - " + IntlHelper.format(toDate);
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("\"$status\" request on $dateStr"),
          Container(
            margin: EdgeInsets.only(top: 7),
            child: AppTable(
              data: rows,
              columnWidths: {
                0: FractionColumnWidth(0.28),
                1: FractionColumnWidth(0.28),
                2: FractionColumnWidth(0.17),
              },
            ),
          )
        ],
      ),
    );
  }
}
