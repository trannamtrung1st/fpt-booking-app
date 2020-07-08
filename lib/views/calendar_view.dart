import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/repos/booking_repo.dart';
import 'package:fptbooking_app/views/booking_detail_view.dart';
import 'package:fptbooking_app/widgets/app_scroll.dart';
import 'package:fptbooking_app/widgets/app_table.dart';
import 'package:fptbooking_app/widgets/calendar.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  CalendarView({key}) : super(key: key);

  static void Function() needRefresh = () {};

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with AutomaticKeepAliveClientMixin {
  static const int SHOWING_VIEW = 1;
  static const int LOADING_DATA = 2;
  int _state = LOADING_DATA;

  DateTime selectedDate = DateTime.now();
  _CalendarViewPresenter _presenter;
  List<dynamic> _bookings;

  void changeSelectedDate(DateTime dateTime) {
    setState(() {
      _bookings = null;
      selectedDate = dateTime;
      _state = LOADING_DATA;
    });
  }

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _presenter = _CalendarViewPresenter(view: this);
    _presenter.handleInitState(context);
    CalendarView.needRefresh = () {
      _keepAlive = false;
      this.updateKeepAlive();
    };
  }

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    super.build(context);
    if (!_keepAlive) {
      _keepAlive = true;
      updateKeepAlive();
    }
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
      _bookings = data;
    });
  }

  Widget _buildShowingViewWidget(BuildContext context) {
    return _mainView();
  }

  //isLoadingData
  bool isLoadingData() => _state == LOADING_DATA;

  Widget _buildLoadingDataWidget(BuildContext context) {
    return _mainView(loading: true);
  }

  void showInvalidMessages(List<String> mess) {
    DialogHelper.showMessage(context: context, title: "Sorry", contents: mess);
  }

  void showError() {
    DialogHelper.showUnknownError(context: this.context);
  }

  void navigateToBookingDetail(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailView(
          id: id,
          type: BookingDetailView.TYPE_CALENDAR_DETAIL,
        ),
      ),
    );
  }

  //widgets
  Widget _mainView({bool loading = false}) {
    return LoadingModal(
      isLoading: loading,
      child: AppScroll(
        onRefresh: _presenter.onRefresh,
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
                children: <Widget>[
                  _currentSelectedDateInfo(),
                  _scheduleTable()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _currentSelectedDateInfo() {
    Widget text = selectedDate == null
        ? Text("Not selected")
        : Text(IntlHelper.format(selectedDate));
    return SimpleInfo(labelText: "Selected date", child: text);
  }

  Widget _scheduleTable() {
    var rows = <AppTableRow>[
      AppTableRow(data: <dynamic>["Time", "Room", "Type", "Status"]),
    ];
    if (_bookings != null)
      for (dynamic o in _bookings) {
        var time = o["from_time"] + " - " + o["to_time"];
        var room = o["room"]["code"];
        var type = o["type"] as String;
        var status = o["status"] ?? "";
        var statusText = ViewHelper.getTextByBookingStatus(status: status);
        rows.add(AppTableRow(
            data: <dynamic>[time, room, type, statusText],
            onTap: type == "Booking" ? () => _presenter.onRowTap(o) : null));
      }
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: AppTable(
        data: rows,
        columnWidths: {
          0: FractionColumnWidth(0.3),
          1: FractionColumnWidth(0.2),
        },
      ),
    );
  }

  bool _keepAlive = true;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => _keepAlive;
}

class _CalendarViewPresenter {
  _CalendarViewState view;

  _CalendarViewPresenter({this.view});

  void handleInitState(BuildContext context) {
    _getBookings(DateTime.now());
  }

  Future<void> onRefresh() {
    return _getBookings(view.selectedDate);
  }

  void onDaySelected(DateTime selected, List<dynamic> list) {
    print(selected);
    view.changeSelectedDate(selected);
    _getBookings(selected);
  }

  Future<void> _getBookings(DateTime date) {
    var success = false;
    return BookingRepo.get(
        fields: "info,room",
        dateStr: IntlHelper.format(date),
        error: view.showError,
        invalid: view.showInvalidMessages,
        success: (data) {
          success = true;
          view.refreshCalendarData(data);
        }).whenComplete(() => {if (!success) view.setShowingViewState()});
  }

  void onRowTap(dynamic data) {
    int id = data["id"];
    print(id);
    view.navigateToBookingDetail(id);
  }
}
