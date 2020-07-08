import 'package:flutter/material.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/repos/booking_repo.dart';
import 'package:fptbooking_app/storages/memory_storage.dart';
import 'package:fptbooking_app/views/approval_list_view.dart';
import 'package:fptbooking_app/views/booking_view.dart';
import 'package:fptbooking_app/views/calendar_view.dart';
import 'package:fptbooking_app/widgets/app_button.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:fptbooking_app/widgets/tag.dart';
import 'package:fptbooking_app/widgets/tags_container.dart';
import 'package:provider/provider.dart';
import 'package:smart_select/smart_select.dart';

class BookingForm extends StatefulWidget {
  final DateTime bookedDate;
  final String fromTime;
  final String toTime;
  final int numOfPeople;
  final dynamic room;
  final Function enableLoading;
  final Function disableLoading;

  BookingForm(
      {key,
      this.enableLoading,
      this.disableLoading,
      this.bookedDate,
      this.fromTime,
      this.toTime,
      this.numOfPeople,
      this.room})
      : super(key: key);

  @override
  _BookingFormState createState() => _BookingFormState(
      room: this.room,
      toTime: toTime,
      disableLoading: disableLoading,
      fromTime: fromTime,
      bookedDate: bookedDate,
      enableLoading: enableLoading,
      numOfPeople: numOfPeople);
}

class _BookingFormState extends State<BookingForm> {
  static const int SHOWING_VIEW = 1;
  int _state = SHOWING_VIEW;
  DateTime bookedDate;
  String fromTime;
  String toTime;
  int numOfPeople;
  dynamic room;
  Map<String, dynamic> booking;
  List<dynamic> _services;
  Map<String, dynamic> _servicesMap;
  LoginContext _loginContext;
  final Function enableLoading;
  final Function disableLoading;

  _BookingFormState(
      {this.room,
      this.enableLoading,
      this.disableLoading,
      this.bookedDate,
      this.fromTime,
      this.toTime,
      this.numOfPeople});

  _BookingFormPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _loginContext = Provider.of<LoginContext>(context, listen: false);
    var tokenData = _loginContext.tokenData;
    booking = {
      'booked_date': IntlHelper.format(bookedDate),
      'from_time': fromTime,
      'to_time': toTime,
      'room_code': room["code"],
      'num_of_people': numOfPeople,
      'attached_services': MemoryStorage.roomTypesMap[room["room_type_code"]]
              ["services"]
          .toList(),
      'book_member': {
        "user_id": tokenData["user_id"],
        "email": tokenData["email"]
      },
      'using_emails': [tokenData["email"]],
      'note': ''
    };
    _services =
        MemoryStorage.roomTypesMap[room["room_type_code"]]["services"].toList();
    _servicesMap = <String, dynamic>{};
    for (dynamic o in _services) _servicesMap[o["code"]] = o;
  }

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    _presenter = _BookingFormPresenter(view: this);
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  void refresh() => setState(() {});

  Future<String> promptEmail() {
    return DialogHelper.prompt(
        inputType: TextInputType.emailAddress,
        context: context,
        title: "Enter an email (@fpt.edu.vn)");
  }

  Widget _buildShowingViewWidget(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            "BOOKING INFORMATION",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          _getTimeInfo(),
          SimpleInfo(
            labelText: "Number of people",
            child: Text(numOfPeople.toString()),
          ),
          _getAttachedServicesTags(),
          _getUsingPersonTag(),
          SimpleInfo(
            labelText: 'Note',
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: "#CCCCCC".toColor())),
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                maxLines: 7,
                onChanged: _presenter.onNoteChanged,
                initialValue: booking["note"] ?? "",
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration.collapsed(
                    hintText: "If you have any notice"),
              ),
            ),
          ),
          Divider(),
          AppButton(
            type: "primary",
            child: Text("SUBMIT"),
            onPressed: _presenter.onSubmit,
          )
        ],
      ),
    );
  }

  void showInvalidMessages(List<String> mess) {
    DialogHelper.showMessage(context: context, title: "Sorry", contents: mess);
  }

  void showError() {
    DialogHelper.showUnknownError(context: this.context);
  }

  void navigateToCalendarView() {
    Navigator.of(context).pop(CalendarView);
  }

  void showSuccessThenNavigateToCalendarView() async {
    await DialogHelper.showMessage(
        context: this.context, title: "Message", contents: ["Successfully"]);
    navigateToCalendarView();
  }

  //widgets
  Widget _getTimeInfo() {
    var timeStr =
        IntlHelper.format(bookedDate) + ", " + fromTime + " - " + toTime;
    return SimpleInfo(
      labelText: "Time",
      child: Text(timeStr),
    );
  }

  Widget _getAttachedServicesTags() {
    var services = booking["attached_services"] as List<dynamic>;
    Widget widget = Text("Nothing");
    if (services != null) {
      var tags = services
          .map((e) => Tag(
                child: Text(e["name"]),
                onRemove: () => _presenter.onRemoveService(e),
              ))
          .toList(growable: true);
      tags.add(_getAddMoreServicesBtn());
      widget = TagsContainer(tags: tags);
    }
    return SimpleInfo(
      labelText: 'Attached services',
      child: widget,
    );
  }

  Widget _getUsingPersonTag() {
    var person = booking["using_emails"] as List<dynamic>;
    Widget widget = Text("Nobody");
    if (person != null) {
      var tags = person
          .map((e) => Tag(
                child: Text(e as String),
                onRemove: () => _presenter.onRemovePerson(e),
              ))
          .toList(growable: true);
      tags.add(_getAddUsingPersonBtn());
      widget = TagsContainer(tags: tags);
    }
    return SimpleInfo(
      labelText: 'Using person(s)',
      child: widget,
    );
  }

  Widget _getAddUsingPersonBtn() {
    return Tag(
        builder: Builder(
            builder: (context) => ButtonTheme(
                minWidth: 30,
                child: FlatButton(
                  padding: EdgeInsets.zero,
                  color: "#CCCCCC".toColor(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: CircleBorder(),
                  onPressed: _presenter.onAddUsingPersonPressed,
                  child: Icon(Icons.add),
                ))));
  }

  Widget _getAddMoreServicesBtn() {
    return SmartSelect<dynamic>.multiple(
      builder: (context, state, showChoices) => Tag(
        builder: Builder(
          builder: (context) => ButtonTheme(
              minWidth: 30,
              child: FlatButton(
                padding: EdgeInsets.zero,
                color: "#CCCCCC".toColor(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: CircleBorder(),
                onPressed: () => showChoices(context),
                child: Icon(Icons.add),
              )),
        ),
      ),
      title: "Available services",
      value: (booking["attached_services"] as List<dynamic>).toList(),
      selected: false,
      onChange: _presenter.onAddMoreServices,
      options: _services
          .map((o) => SmartSelectOption<dynamic>(value: o, title: o["name"]))
          .toList(),
      modalType: SmartSelectModalType.popupDialog,
    ).build(context);
  }
}

class _BookingFormPresenter {
  _BookingFormState view;

  _BookingFormPresenter({this.view});

  void onRemoveService(dynamic data) {
    var services = view.booking["attached_services"] as List<dynamic>;
    services.removeWhere((element) => element["code"] == data["code"]);
    view.refresh();
  }

  void onSubmit() {
    view.enableLoading();
    var success = false;
    BookingRepo.createBooking(
            data: view.booking,
            error: view.showError,
            success: (id) {
              success = true;
              BookingView.needRefresh();
              CalendarView.needRefresh();
              ApprovalListView.needRefresh();
              view.showSuccessThenNavigateToCalendarView();
            },
            invalid: view.showInvalidMessages)
        .whenComplete(() => {
              if (!success) {view.disableLoading()}
            });
  }

  void onNoteChanged(String val) {
    view.booking["note"] = val;
  }

  void onRemovePerson(String person) {
    var personList = view.booking["using_emails"] as List<dynamic>;
    personList.remove(person);
    view.refresh();
  }

  void onAddUsingPersonPressed() async {
    var email = await view.promptEmail();
    if (email == null) return;
    var personList = view.booking["using_emails"] as List<dynamic>;
    personList.add(email);
    view.refresh();
  }

  void onAddMoreServices(List<dynamic> list) {
    view.booking["attached_services"] = list;
    view.refresh();
  }
}
