import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
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

class _BookingViewState extends State<BookingView> {
  static const int SHOWING_VIEW = 1;
  static const int LOADING_DATA = 2;
  int _state = LOADING_DATA;

  String _fromTime;
  String _toTime;
  String _roomType = "Classroom";
  DateTime _selectedDate = DateTime.now();
  _BookingViewPresenter _presenter;
  List<dynamic> _rooms;

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

  void changeRoomType(String value) => setState(() {
        _roomType = value;
      });

  @override
  void initState() {
    super.initState();
    _presenter = _BookingViewPresenter(view: this);
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

  void refreshBookingData(List<dynamic> data) {
    setState(() {
      _state = SHOWING_VIEW;
      _rooms = data;
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
    return LoadingModal(
        isLoading: loading,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Calendar(
                    initFormat: CalendarFormat.month,
                    onDaySelected: _presenter.onDaySelected),
                Container(
                  margin: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SimpleInfo(
                        labelText: "Time filter",
                        marginBetween: 0,
                        marginBottom: 7,
                        child: Row(
                          children: <Widget>[
                            _timeButton(
                                timeStr: _fromTime,
                                onPressed: _presenter.onFromTimePressed),
                            Text('-  '),
                            _timeButton(
                                timeStr: _toTime,
                                onPressed: _presenter.onToTimePressed)
                          ],
                        ),
                      ),
                      SimpleInfo(
                        labelText: "Number of people",
                        marginBottom: 14,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 14),
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
                                onPressed: () {},
                                child: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                )),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
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
        child: SmartSelect<String>.single(
          builder: (context, state, showChoices) => MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minWidth: double.infinity,
            padding: EdgeInsets.all(10),
            child: Container(
              width: double.infinity,
              child: Text(
                _roomType,
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
          options: [
            SmartSelectOption(value: "Classroom", title: "Classroom"),
            SmartSelectOption(value: "Studio", title: "Studio"),
            SmartSelectOption(value: "Library", title: "Library"),
          ],
          modalType: SmartSelectModalType.bottomSheet,
        ));
  }
}

class _BookingViewPresenter {
  _BookingViewState view;

  _BookingViewPresenter({this.view});

  void handleInitState(BuildContext context) {
    view.setShowingViewState();
  }

  void onDaySelected(DateTime selected, List<dynamic> list) {
    print(selected);
    view.changeSelectedDate(selected);
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

  void onRoomTypeChanged(String val) {
    view.changeRoomType(val);
  }
}
