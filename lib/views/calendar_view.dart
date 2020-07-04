import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/repos/booking_repo.dart';
import 'package:fptbooking_app/widgets/app_table.dart';
import 'package:fptbooking_app/widgets/calendar.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:fptbooking_app/widgets/tab_view.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  CalendarView({key}) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  static const int SHOWING_VIEW = 1;
  static const int LOADING_DATA = 2;
  int _state = LOADING_DATA;

  DateTime _selectedDate = DateTime.now();
  _CalendarViewPresenter _presenter;
  List<dynamic> _data;

  void changeSelectedDate(DateTime dateTime) {
    setState(() {
      _selectedDate = dateTime;
      _state = LOADING_DATA;
    });
  }

  @override
  void initState() {
    super.initState();
    _presenter = _CalendarViewPresenter(view: this);
    _presenter.handleInitState(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingData()) {
      return _buildLoadingDataWidget(context);
    }
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  void refreshCalendarData(List<dynamic> data) {
    setState(() {
      _state = SHOWING_VIEW;
      _data = data;
    });
  }

  Widget _buildShowingViewWidget(BuildContext context) {
    return LoadingModal(
      isLoading: false,
      child: _tabView(),
    );
  }

  //isLoadingData
  bool isLoadingData() => _state == LOADING_DATA;

  Widget _buildLoadingDataWidget(BuildContext context) {
    return LoadingModal(
      isLoading: true,
      child: _tabView(),
    );
  }

  void showInvalidMessages(List<String> mess) {
    DialogHelper.showMessage(context: context, title: "Sorry", contents: mess);
  }

  void showError() {
    DialogHelper.showUnknownError(context: this.context);
  }

  //widgets
  Widget _tabView() {
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
        : Text(IntlHelper.format(_selectedDate));
    return SimpleInfo(labelText: "Selected date", child: text);
  }

  Widget _scheduleTable() {
    var rows = <AppTableRow>[
      AppTableRow(data: <dynamic>["Time", "Room", "Type", "Status"]),
    ];
    if (_data != null)
      for (dynamic o in _data) {
        var time = o["from_time"] + " - " + o["to_time"];
        var room = o["room"]["code"];
        var type = o["type"] as String;
        var status = o["status"] ?? "";
        var statusText = _getTextByStatus(status);
        rows.add(AppTableRow(
            data: <dynamic>[time, room, type, statusText],
            onTap: type == "Booking" ? () => _presenter.onRowTab(o) : null));
      }
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: AppTable(
        data: rows,
        columnWidths: {
          0: FractionColumnWidth(0.3),
          1: FractionColumnWidth(0.2),
        },
      ),
    );
  }

  Widget _getTextByStatus(String status) {
    Color color = Colors.grey;
    switch (status) {
      case "Finished":
        color = Colors.green;
        break;
      case "Denied":
        color = Colors.red;
        break;
    }
    return Text(status, style: TextStyle(color: color));
  }
}

class _CalendarViewPresenter {
  _CalendarViewState view;

  _CalendarViewPresenter({this.view});

  void handleInitState(BuildContext context) {
    _getBookings(DateTime.now());
  }

  void onDaySelected(DateTime selected, List<dynamic> list) {
    print(selected);
    view.changeSelectedDate(selected);
    _getBookings(selected);
  }

  void _getBookings(DateTime date) {
    var success = false;
    BookingRepo.get(
        fields: "info,room",
        dateStr: IntlHelper.format(date),
        error: view.showError,
        invalid: view.showInvalidMessages,
        success: (data) {
          success = true;
          view.refreshCalendarData(data);
        }).whenComplete(() => {if (!success) view.setShowingViewState()});
  }

  void onRowTab(dynamic data) {
    print(data["id"]);
  }
}
