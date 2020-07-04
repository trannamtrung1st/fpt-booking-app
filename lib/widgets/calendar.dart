import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  final CalendarFormat initFormat;
  final Function(DateTime selected, List<dynamic> list) onDaySelected;

  Calendar({this.initFormat = CalendarFormat.month, this.onDaySelected});

  @override
  _CalendarState createState() =>
      _CalendarState(calendarFormat: initFormat, onDaySelected: onDaySelected);
}

class _CalendarState extends State<Calendar> {
  CalendarController _calendarController;
  CalendarFormat calendarFormat;
  Function(DateTime selected, List<dynamic> list) onDaySelected;

  _CalendarState({this.calendarFormat, this.onDaySelected});

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      calendarController: _calendarController,
      initialCalendarFormat: calendarFormat,
      onDaySelected: onDaySelected,
      calendarStyle: CalendarStyle(
          selectedColor: Colors.deepOrange, todayColor: "#DDDDDD".toColor()),
    );
  }
}
