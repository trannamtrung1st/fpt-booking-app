import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/app/refreshable.dart';
import 'package:fptbooking_app/contexts/page_context.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/navigations/main_nav.dart';
import 'package:fptbooking_app/repos/room_repo.dart';
import 'package:fptbooking_app/storages/memory_storage.dart';
import 'package:fptbooking_app/views/calendar_view.dart';
import 'package:fptbooking_app/views/frags/available_room_list.dart';
import 'package:fptbooking_app/views/room_detail_view.dart';
import 'package:fptbooking_app/widgets/app_scroll.dart';
import 'package:fptbooking_app/widgets/calendar.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:provider/provider.dart';
import 'package:smart_select/smart_select.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingView extends StatefulWidget {
  BookingView({key}) : super(key: key);

  @override
  _BookingViewState createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> with Refreshable {
  static const int SHOWING_VIEW = 1;
  static const int LOADING_DATA = 2;
  static const int AFTER_SEARCH = 3;
  int _state = SHOWING_VIEW;

  String _fromTime;
  String _toTime;
  dynamic _roomType = MemoryStorage.roomTypesMap.values.first;
  int _numOfPeople;
  DateTime _selectedDate = DateTime.now();
  _BookingViewPresenter _presenter;
  List<dynamic> rooms;
  final GlobalKey roomCardsKey = GlobalKey(debugLabel: "_roomCardsKey");
  PageContext pageContext;

  void changeSelectedDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void changeFromTime(TimeOfDay time) {
    setState(() {
      _fromTime = time?.format(context) ?? null;
    });
  }

  void changeToTime(TimeOfDay time) {
    setState(() {
      _toTime = time?.format(context) ?? null;
    });
  }

  void changeRoomType(dynamic value) => setState(() {
        _roomType = value;
      });

  void refresh<T>({T refreshParam}) {
    this.needRefresh = false;
    _presenter.onRefresh();
  }

  void navigateToRoomDetail(String code, DateTime date, String fromTime,
      String toTime, int numOfPeople) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomDetailView(
          code: code,
          type: RoomDetailView.TYPE_BOOKING,
          extraData: {
            'fromTime': fromTime,
            'toTime': toTime,
            'bookedDate': date,
            'numOfPeople': numOfPeople,
          },
        ),
      ),
    ).then((bookedDate) {
      if (bookedDate != null)
        MainNav.navigate(refreshParam: bookedDate, type: CalendarView);
      else {
        _presenter.onCancelBooking(code);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    pageContext = Provider.of<PageContext>(context, listen: false);
    pageContext.setRefreshable(BookingView, this);
    _presenter = _BookingViewPresenter(view: this);
    _presenter.handleInitState(context);
  }

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    if (isLoadingData()) {
      return _buildLoadingDataWidget(context);
    }
    if (_isAfterSearch()) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _presenter.handleAfterSearch(context));
    }
    return _buildShowingViewWidget(context);
  }

  //isAfterSearch
  bool _isAfterSearch() => _state == AFTER_SEARCH;

  void setAfterSearchState() => _state = AFTER_SEARCH;

  //isShowingView
  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  void refreshRoomData(List<dynamic> data) {
    setState(() {
      _state = AFTER_SEARCH;
      rooms = data;
    });
  }

  void loadRoomData() {
    setState(() {
      _state = LOADING_DATA;
      rooms = null;
    });
  }

  Widget _buildShowingViewWidget(BuildContext context) {
    return _mainView();
  }

  //isLoadingData
  void setLoadingDataState() => setState(() {
        _state = LOADING_DATA;
      });

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

  //widgets
  Widget _mainView({bool loading = false}) {
    var widgets = <Widget>[
      Calendar(
          initFormat: CalendarFormat.month,
          onDaySelected: _presenter.onDaySelected),
      Container(
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _filterWidgets(),
        ),
      ),
    ];
    if (rooms != null)
      widgets.add(AvailableRoomList(
        key: roomCardsKey,
        toTime: _toTime,
        fromTime: _fromTime,
        numOfPeople: _numOfPeople,
        onRoomPressed: _presenter.onRoomPressed,
        rooms: rooms,
        selectedDate: _selectedDate,
      ));
    return LoadingModal(
      isLoading: loading,
      child: AppScroll(
        onRefresh: _presenter.onRefresh,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: widgets),
      ),
    );
  }

  List<Widget> _filterWidgets() {
    var widgets = <Widget>[
      SimpleInfo(
        labelText: "Time filter",
        marginBetween: 0,
        child: Row(
          children: <Widget>[
            _timeButton(
                timeStr: _fromTime, onPressed: _presenter.onFromTimePressed),
            Text('-  '),
            _timeButton(timeStr: _toTime, onPressed: _presenter.onToTimePressed)
          ],
        ),
      ),
      SimpleInfo(
        labelText: "Number of people",
        containerMargin: EdgeInsets.only(bottom: 14),
        child: TextFormField(
          autofocus: false,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 14),
          initialValue: _numOfPeople?.toString(),
          onChanged: (value) =>
              _numOfPeople = value.isNotEmpty ? int.parse(value) : null,
          decoration: InputDecoration(
              hintText: "Input a number",
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: "#CCCCCC".toColor())),
              contentPadding: EdgeInsets.only(bottom: 7),
              isDense: true),
        ),
      ),
      _roomTypeSelect(),
      Row(
        children: <Widget>[
          Spacer(),
          ButtonTheme(
            minWidth: 0,
            height: 40,
            buttonColor: Colors.orange,
            child: RaisedButton(
                onPressed: _presenter.onSearchPressed,
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                )),
          )
        ],
      ),
    ];
    return widgets;
  }

  Widget _timeButton({@required String timeStr, Function onPressed}) {
    return MaterialButton(
      onPressed: onPressed,
      minWidth: 0,
      height: 0,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.fromLTRB(0, 7, 7, 7),
      child: Text(
        timeStr ?? "Not set",
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget _roomTypeSelect() {
    return SimpleInfo(
        labelText: "Room type",
        containerMargin: EdgeInsets.only(bottom: 14),
        child: SmartSelect<dynamic>.single(
          builder: (context, state, showChoices) => MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minWidth: double.infinity,
            padding: EdgeInsets.all(10),
            child: Container(
              width: double.infinity,
              child: Text(
                _roomType["name"],
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ),
            shape: ContinuousRectangleBorder(
                side: BorderSide(color: "#CCCCCC".toColor())),
            onPressed: () => showChoices(context),
          ),
          title: "Room type",
          value: _roomType,
          onChange: _presenter.onRoomTypeChanged,
          options: MemoryStorage.roomTypesMap.values
              .map(
                  (o) => SmartSelectOption<dynamic>(value: o, title: o["name"]))
              .toList(),
          modalType: SmartSelectModalType.bottomSheet,
        ));
  }
}

class _BookingViewPresenter {
  _BookingViewState view;

  _BookingViewPresenter({this.view});

  void handleInitState(BuildContext context) {}

  Future<void> onRefresh() {
    return onSearchPressed();
  }

  void onCancelBooking(String code) {
    view.setLoadingDataState();
    RoomRepo.cancelHangingRoom(
      code: code,
//        error: view.showError,
//        invalid: view.showInvalidMessages
    ).whenComplete(() {
      view.refresh();
    });
  }

  void handleAfterSearch(BuildContext context) {
    view.setShowingViewState();
    if (view.rooms != null)
      Scrollable.ensureVisible(view.roomCardsKey.currentContext,
          duration: Duration(seconds: 1));
  }

  void onDaySelected(DateTime selected, List<dynamic> list) {
    print(selected);
    view.changeSelectedDate(selected);
  }

  void onRoomPressed(dynamic data, DateTime date, String fromTime,
      String toTime, int numOfPeople) {
    String code = data["code"];
    print(code);
    view.navigateToRoomDetail(code, date, fromTime, toTime, numOfPeople);
  }

  void onFromTimePressed() {
    showTimePicker(
            initialTime: TimeOfDay(hour: 07, minute: 00), context: view.context)
        .then((time) => view.changeFromTime(time));
  }

  void onToTimePressed() {
    showTimePicker(
            initialTime: TimeOfDay(hour: 07, minute: 00), context: view.context)
        .then((time) => view.changeToTime(time));
  }

  void onRoomTypeChanged(dynamic val) {
    view.changeRoomType(val);
  }

  Future<void> onSearchPressed() async {
    if (view._selectedDate == null ||
        view._fromTime == null ||
        view._toTime == null ||
        view._numOfPeople == null) {
      view.showInvalidMessages(["Please fill all the required fields"]);
      return;
    }
    var mess = <String>[];
    var fromTime = IntlHelper.parseTimeOfDay(view._fromTime);
    var toTime = IntlHelper.parseTimeOfDay(view._toTime);
    if (IntlHelper.compareTimeOfDay(fromTime, toTime) >= 0)
      mess.add("Time range not valid");
    if (view._numOfPeople <= 0) mess.add("Number of people must be at least 1");
    if (mess.length > 0) {
      view.showInvalidMessages(mess);
      return;
    }
    view.loadRoomData();
    return _getAvailableRooms();
  }

  Future<void> _getAvailableRooms() {
    var success = false;
    var dateStr = IntlHelper.format(view._selectedDate);
    return RoomRepo.getAvailableRooms(
        dateStr: dateStr,
        fromTime: view._fromTime,
        toTime: view._toTime,
        numOfPeople: view._numOfPeople,
        roomTypeCode: view._roomType["code"],
        invalid: view.showInvalidMessages,
        error: view.showError,
        success: (data) {
          success = true;
          view.refreshRoomData(data);
        }).whenComplete(() {
      if (!success) view.setShowingViewState();
    });
  }
}
