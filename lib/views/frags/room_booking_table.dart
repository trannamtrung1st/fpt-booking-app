import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/widgets/app_table.dart';
import 'package:intl/intl.dart';

class RoomBookingTable extends StatefulWidget {
  final List<dynamic> bookings;
  final Function(dynamic val) onRowTap;
  final String status;
  final DateTime fromDate;
  final DateTime toDate;
  final String roomCode;

  RoomBookingTable(
      {this.bookings,
      this.onRowTap,
      this.status,
      this.fromDate,
      this.toDate,
      this.roomCode});

  @override
  _RoomBookingTableState createState() => _RoomBookingTableState(
      bookings: bookings,
      onRowTap: onRowTap,
      status: status,
      roomCode: roomCode,
      fromDate: fromDate,
      toDate: toDate);
}

class _RoomBookingTableState extends State<RoomBookingTable> {
  List<dynamic> bookings;
  Function(dynamic val) onRowTap;
  final String status;
  final DateTime fromDate;
  final DateTime toDate;
  final String roomCode;

  _RoomBookingTableState(
      {this.bookings,
      this.onRowTap,
      this.status,
      this.fromDate,
      this.toDate,
      this.roomCode});

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    var rows = <AppTableRow>[
      AppTableRow(data: <dynamic>[
        "Booked date",
        "Time",
        "Booked person",
        "Status",
      ]),
    ];
    if (bookings != null)
      for (dynamic o in bookings) {
        var time = o["from_time"] + ' - ' + o["to_time"];
        var bookedBy =
            (o["book_member"]["email"] as String).replaceAll("@fpt.edu.vn", "");
        var status = o["status"] ?? "";
        var statusText = ViewHelper.getTextByBookingStatus(status: status);
        var bookedDate = o["booked_date"]["display"];
        rows.add(AppTableRow(
            data: <dynamic>[bookedDate, time, bookedBy, statusText],
            onTap: () => this.onRowTap(o)));
      }
    var dateStr =
        IntlHelper.format(fromDate) + " - " + IntlHelper.format(toDate);
    var finalStatus = status.isEmpty ? "All" : status;
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text("\"$finalStatus\" bookings on $dateStr"),
          ),
          Container(
            margin: EdgeInsets.only(top: 7),
            child: AppTable(
              padding: EdgeInsets.zero,
              data: rows,
              width: MediaQuery.of(context).size.width * 1.5,
              columnWidths: {
                0: FractionColumnWidth(0.2),
                1: FractionColumnWidth(0.22),
                2: FractionColumnWidth(0.33),
                3: FractionColumnWidth(0.25),
              },
            ),
          )
        ],
      ),
    );
  }
}
