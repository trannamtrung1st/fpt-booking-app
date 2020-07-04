import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/widgets/app_table.dart';
import 'package:fptbooking_app/widgets/calendar.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:fptbooking_app/widgets/tab_view.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _selectedDate = DateTime.now();
  _CalendarViewPresenter _presenter;

  void setSelectedDate(DateTime dateTime) {
    setState(() {
      _selectedDate = dateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    _presenter = _CalendarViewPresenter(view: this);
    return TabView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Calendar(
              initFormat: CalendarFormat.week,
              onDaySelected: _presenter.onDaySelected),
          Container(
            margin: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[_currentSelectedDateInfo(), _scheduleTable()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentSelectedDateInfo() {
    Widget text = _selectedDate == null
        ? Text("Not selected")
        : Text(IntlHelper.format(_selectedDate, "dd/MM/yyyy"));
    return SimpleInfo(labelText: "Selected date", child: text);
  }

  Widget _scheduleTable() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: AppTable(
        data: <AppTableRow>[
          AppTableRow(data: <dynamic>["Time", "Room", "Type", "Status"]),
          AppTableRow(
              data: <dynamic>["Time", "Room", "Type", "Status"],
              onTap: () => _presenter.onRowTab()),
          AppTableRow(data: <dynamic>["Time", "Room", "Type", "Status"]),
          AppTableRow(data: <dynamic>["Time", "Room", "Type", "Status"]),
          AppTableRow(data: <dynamic>["Time", "Room", "Type", "Status"]),
        ],
      ),
    );
  }
}

class _CalendarViewPresenter {
  _CalendarViewState view;

  _CalendarViewPresenter({this.view});

  onDaySelected(DateTime selected, List<dynamic> list) {
    print(selected);
    view.setSelectedDate(selected);
  }

  onRowTab() {
    print("tabbed");
  }
}
