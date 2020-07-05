import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/repos/room_repo.dart';
import 'package:fptbooking_app/storages/memory_storage.dart';
import 'package:fptbooking_app/views/room_detail_view.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/calendar.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:smart_select/smart_select.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingView extends StatefulWidget {
  BookingView({key}) : super(key: key);

  @override
  _BookingViewState createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView>
    with AutomaticKeepAliveClientMixin {
  static const int SHOWING_VIEW = 1;
  static const int LOADING_DATA = 2;
  static const int AFTER_SEARCH = 3;
  int _state = LOADING_DATA;

  String _fromTime;
  String _toTime;
  dynamic _roomType = MemoryStorage.roomTypes[0];
  int _numOfPeople;
  DateTime _selectedDate = DateTime.now();
  _BookingViewPresenter _presenter;
  List<dynamic> rooms;
  final GlobalKey roomCardsKey = GlobalKey(debugLabel: "_roomCardsKey");
  ScrollController _scrollController = ScrollController(keepScrollOffset: true);

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

  void navigateToRoomDetail(String code) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomDetailView(
          code: code,
          type: RoomDetailView.TYPE_BOOKING,
          extraData: {
            'fromTime': _fromTime,
            'toTime': _toTime,
            'bookedDate': _selectedDate,
            'numOfPeople': _numOfPeople,
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _presenter = _BookingViewPresenter(view: this);
    _presenter.handleInitState(context);
//    this.updateKeepAlive();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (isLoadingData()) {
      return _buildLoadingDataWidget(context);
    }
    if (_isAfterSearch())
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _presenter.handleAfterSearch(context));
    return _buildShowingViewWidget(context);
  }

  //isAfterSearch
  bool _isAfterSearch() => _state == AFTER_SEARCH;

  void setAfterSearchState() => _state = AFTER_SEARCH;

  //isShowingView
  void setShowingViewState({bool rebuild = true}) => rebuild
      ? setState(() {
          _state = SHOWING_VIEW;
        })
      : _state = SHOWING_VIEW;

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
    if (rooms != null) widgets.add(_getRoomsCard());
    return LoadingModal(
      isLoading: loading,
      child: SingleChildScrollView(
        controller: _scrollController,
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
        marginBottom: 7,
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
        marginBottom: 14,
        child: TextFormField(
          autofocus: false,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 14),
          onChanged: (value) =>
              _numOfPeople = value.isNotEmpty ? int.parse(value) : null,
          decoration: InputDecoration(
              hintText: "Input a number",
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

  Widget _getRoomsCard() {
    var dateStr = IntlHelper.format(_selectedDate);
    var cardWidgets = <Widget>[
      Text("Available rooms on $dateStr from $_fromTime - $_toTime")
    ];
    var card = AppCard(
      key: roomCardsKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cardWidgets,
      ),
    );

    for (dynamic o in rooms) {
      cardWidgets.add(AppCard(
        onTap: () => _presenter.onRoomPressed(o),
        margin: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(right: 20),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Icon(
                          Icons.school,
                          size: 45,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(7),
                        margin: EdgeInsets.only(bottom: 7),
                        decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent,
                            shape: BoxShape.circle),
                      ),
                      Text(
                        "EMPTY",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: o["code"],
                        style: TextStyle(fontSize: 17, color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: "   " + o["room_type"]["name"],
                              style: TextStyle(
                                  color: Colors.orange, fontSize: 14)),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.fullscreen,
                          color: Colors.grey,
                          size: 22,
                        ),
                        Text(
                          " " + o["area_size"].toString() + " m2",
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.people,
                          color: Colors.grey,
                          size: 22,
                        ),
                        Text(
                          " At most " + o["people_capacity"].toString(),
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ));
    }
    return card;
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
        marginBottom: 14,
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
            shape:
                ContinuousRectangleBorder(side: BorderSide(color: Colors.grey)),
            onPressed: () => showChoices(context),
          ),
          title: "Room type",
          value: _roomType,
          onChange: _presenter.onRoomTypeChanged,
          options: MemoryStorage.roomTypes
              .map(
                  (o) => SmartSelectOption<dynamic>(value: o, title: o["name"]))
              .toList(),
          modalType: SmartSelectModalType.bottomSheet,
        ));
  }

  bool _keepAlive = true;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => _keepAlive;
}

class _BookingViewPresenter {
  _BookingViewState view;

  _BookingViewPresenter({this.view});

  void handleInitState(BuildContext context) {
    view.setShowingViewState();
  }

  void handleAfterSearch(BuildContext context) {
    if (view.rooms != null)
      Scrollable.ensureVisible(view.roomCardsKey.currentContext,
          duration: Duration(seconds: 1));
    view.setShowingViewState(rebuild: false);
  }

  void onDaySelected(DateTime selected, List<dynamic> list) {
    print(selected);
    view.changeSelectedDate(selected);
  }

  void onRoomPressed(dynamic data) {
    String code = data["code"];
    print(code);
    view.navigateToRoomDetail(code);
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

  void onSearchPressed() {
    if (view._selectedDate == null ||
        view._fromTime == null ||
        view._toTime == null ||
        view._numOfPeople == null)
      return view.showInvalidMessages(["Please fill all the required fields"]);
    view.loadRoomData();
    _getAvailableRooms();
  }

  void _getAvailableRooms() {
    var success = false;
    var dateStr = IntlHelper.format(view._selectedDate);
    RoomRepo.getAvailableRooms(
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
        }).whenComplete(() => {if (!success) view.setShowingViewState()});
  }
}
