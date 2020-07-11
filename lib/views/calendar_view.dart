import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/app/refreshable.dart';
import 'package:fptbooking_app/contexts/page_context.dart';
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
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  final DateTime initDate;

  CalendarView({this.initDate, key}) : super(key: key);

  @override
  _CalendarViewState createState() =>
      _CalendarViewState(initDate: this.initDate);
}

class _CalendarViewState extends State<CalendarView>
    with Refreshable, AutomaticKeepAliveClientMixin {
  static const int SHOWING_VIEW = 1;
  static const int LOADING_DATA = 2;
  int _state = LOADING_DATA;

  DateTime selectedDate;
  _CalendarViewPresenter _presenter;
  List<dynamic> _bookings;
  PageContext pageContext;
  CalendarController _calendarController = CalendarController();

  _CalendarViewState({DateTime initDate}) {
    selectedDate = initDate ?? DateTime.now();
  }

  void changeSelectedDate(DateTime dateTime) {
    setState(() {
      _bookings = null;
      selectedDate = dateTime;
      _state = LOADING_DATA;
    });
  }

  void refresh<T>({T refreshParam}) {
    this.needRefresh = false;
    setState(() {
      if (refreshParam != null) {
        selectedDate = refreshParam as DateTime;
        _calendarController.setSelectedDay(selectedDate,
            isProgrammatic: true, runCallback: false, animate: false);
      }
      _state = LOADING_DATA;
      _bookings = null;
      _presenter.onRefresh();
    });
  }

  @override
  void initState() {
    super.initState();
    _presenter = _CalendarViewPresenter(view: this);
    pageContext = Provider.of<PageContext>(context, listen: false);
    pageContext.setRefreshable(CalendarView, this);
    _presenter.handleInitState(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("build ${this.runtimeType}");
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
          type: BookingDetailView.TYPE_BOOKING_DETAIL,
        ),
      ),
    ).then((value) {
      if (this.needRefresh) {
        refresh();
      }
    });
  }

  //widgets
  Widget _mainView({bool loading = false}) {
    var widgets = <Widget>[
      Container(
        margin: EdgeInsets.all(15),
        child: _currentSelectedDateInfo(),
      ),
      _scheduleTable()
    ];
    if (_bookings != null && _bookings.length == 0)
      widgets.add(Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 15),
        child: Text(
          "You have nothing on this day",
          textAlign: TextAlign.center,
        ),
      ));

    return LoadingModal(
      isLoading: loading,
      child: AppScroll(
        onRefresh: _presenter.onRefresh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Calendar(
                calendarController: this._calendarController,
                initDate: selectedDate,
                initFormat: CalendarFormat.week,
                onDaySelected: _presenter.onDaySelected),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            ),
          ],
        ),
      ),
    );
  }

  Widget _currentSelectedDateInfo() {
    Widget text = selectedDate == null
        ? Text("Not selected")
        : SelectableText(IntlHelper.format(selectedDate));
    return SimpleInfo(labelText: "Selected date", child: text);
  }

  Widget _scheduleTable() {
    var rows = <AppTableRow>[
      AppTableRow(data: <dynamic>["Time", "Room", "Subject", "Status", "Type"]),
    ];
    if (_bookings != null)
      for (dynamic o in _bookings) {
        var time = o["from_time"] + " - " + o["to_time"];
        var room = o["room"]["code"];
        var type = (o["type"] as String);
        var sub = type == "Booking" ? "" : o["code"];
        var status = o["status"] ?? "";
        var statusText = ViewHelper.getTextByBookingStatus(status: status);
        rows.add(AppTableRow(
            data: <dynamic>[time, room, sub, statusText, type],
            onTap: type == "Booking" ? () => _presenter.onRowTap(o) : null));
      }
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: AppTable(
        data: rows,
        width: MediaQuery.of(context).size.width * 1.3,
        columnWidths: {
          0: FractionColumnWidth(0.25),
          1: FractionColumnWidth(0.13),
          2: FractionColumnWidth(0.17),
        },
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => !needRefresh;
}

class _CalendarViewPresenter {
  _CalendarViewState view;

  _CalendarViewPresenter({this.view});

  void handleInitState(BuildContext context) {
    _getCalendar(view.selectedDate);
  }

  Future<void> onRefresh() {
    return _getCalendar(view.selectedDate);
  }

  void onDaySelected(DateTime selected, List<dynamic> list) {
    print(selected);
    view.changeSelectedDate(selected);
    _getCalendar(selected);
  }

  Future<void> _getCalendar(DateTime date) {
    var success = false;
    return BookingRepo.getCalendar(
        dateStr: IntlHelper.format(date),
        error: view.showError,
        invalid: view.showInvalidMessages,
        success: (data) {
          success = true;
          view.refreshCalendarData(data);
        }).whenComplete(() {
      if (!success) view.setShowingViewState();
    });
  }

  void onRowTap(dynamic data) {
    int id = data["id"];
    print(id);
    view.navigateToBookingDetail(id);
  }
}
