import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  final CalendarFormat initFormat;
  final Function(DateTime selected, List<dynamic> list) onDaySelected;
  final DateTime initDate;

  Calendar(
      {this.initDate,
      this.initFormat = CalendarFormat.month,
      this.onDaySelected});

  @override
  _CalendarState createState() => _CalendarState(
      calendarFormat: initFormat,
      onDaySelected: onDaySelected,
      initDate: this.initDate);
}

class _CalendarState extends State<Calendar> {
  CalendarController _calendarController;
  CalendarFormat calendarFormat;
  Function(DateTime selected, List<dynamic> list) onDaySelected;
  final DateTime initDate;

  _CalendarState({this.calendarFormat, this.onDaySelected, this.initDate});

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
    print("build ${this.runtimeType}");
    return TableCalendar(
      calendarController: _calendarController,
      initialCalendarFormat: calendarFormat,
      initialSelectedDay: initDate,
      onDaySelected: onDaySelected,
      calendarStyle: CalendarStyle(
          selectedColor: Colors.orange, todayColor: "#CCCCCC".toColor()),
    );
  }
}
