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
    print("build ${this.runtimeType}");
    var rows = <AppTableRow>[
      AppTableRow(data: <dynamic>[
        "Sent date",
        "Booked person",
        "Status",
        "Booked date",
        "Room"
      ]),
    ];
    if (bookings != null)
      for (dynamic o in bookings) {
        var date = o["sent_date"]["display"].split(' ')[0];
        var bookedBy =
            (o["book_member"]["email"] as String).replaceAll("@fpt.edu.vn", "");
        var status = o["status"] ?? "";
        var statusText = ViewHelper.getTextByBookingStatus(status: status);
        var bookedDate = o["booked_date"]["display"];
        var room = o["room"]["code"];
        rows.add(AppTableRow(
            data: <dynamic>[date, bookedBy, statusText, bookedDate, room],
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
            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Text("\"$finalStatus\" request on $dateStr"),
          ),
          Container(
            margin: EdgeInsets.only(top: 7),
            child: AppTable(
              data: rows,
              width: MediaQuery.of(context).size.width * 1.5,
              columnWidths: {
                0: FractionColumnWidth(0.18),
                1: FractionColumnWidth(0.3),
                2: FractionColumnWidth(0.2),
                3: FractionColumnWidth(0.2),
              },
            ),
          )
        ],
      ),
    );
  }
}
