import 'package:flutter/material.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/widgets/app_button.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:fptbooking_app/widgets/tag.dart';
import 'package:fptbooking_app/widgets/tags_container.dart';
import 'package:smart_select/smart_select.dart';

class BookingForm extends StatefulWidget {
  final DateTime bookedDate;
  final String fromTime;
  final String toTime;
  final int numOfPeople;
  final dynamic room;

  BookingForm(
      {key,
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
      fromTime: fromTime,
      bookedDate: bookedDate,
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
  List<dynamic> _services = <dynamic>[
    {"code": "PRJ", "name": "Projector"},
    {"code": "MS", "name": "Mentor/Support"},
    {"code": "TB", "name": "Tea-break"}
  ];
  Map<String, dynamic> _servicesMap;

  _BookingFormState(
      {this.room,
      this.bookedDate,
      this.fromTime,
      this.toTime,
      this.numOfPeople});

  _BookingFormPresenter _presenter;

  @override
  void initState() {
    super.initState();
    booking = {
      'booked_date': bookedDate,
      'from_time': fromTime,
      'to_time': toTime,
      'room_code': room["code"],
      'num_of_people': numOfPeople,
      'service_codes':
          room["available_services"].map((e) => e["code"]).toList(),
      'book_person': ["trungtnse13@fpt.edu.vn"],
      'using_person': ["trungtnse13@fpt.edu.vn"],
      'note': ''
    };
    _servicesMap = {
      "PRJ": _services[0],
      "MS": _services[1],
      "TB": _services[2],
    };
  }

  @override
  Widget build(BuildContext context) {
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
    var services = booking["service_codes"].map((e) => _servicesMap[e]).toList()
        as List<dynamic>;
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
    var person = booking["using_person"] as List<dynamic>;
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
    return SmartSelect<String>.multiple(
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
      value: (booking["service_codes"] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      selected: false,
      onChange: _presenter.onAddMoreServices,
      options: _services
          .map((o) =>
              SmartSelectOption<String>(value: o["code"], title: o["name"]))
          .toList(),
      modalType: SmartSelectModalType.popupDialog,
    ).build(context);
  }
}

class _BookingFormPresenter {
  _BookingFormState view;

  _BookingFormPresenter({this.view});

  void onRemoveService(dynamic data) {
    var services = view.booking["service_codes"] as List<dynamic>;
    services.remove(data["code"]);
    view.refresh();
  }

  void onSubmit() {
    print(view.booking);
  }

  void onNoteChanged(String val) {
    view.booking["note"] = val;
  }

  void onRemovePerson(String person) {
    var personList = view.booking["using_person"] as List<dynamic>;
    personList.remove(person);
    view.refresh();
  }

  void onAddUsingPersonPressed() async {
    var email = await view.promptEmail();
    if (email == null) return;
    var personList = view.booking["using_person"] as List<dynamic>;
    personList.add(email);
    view.refresh();
  }

  void onAddMoreServices(List<String> list) {
    view.booking["service_codes"] = list;
    view.refresh();
  }
}
