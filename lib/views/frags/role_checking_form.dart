import 'package:flutter/material.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/repos/room_repo.dart';
import 'package:fptbooking_app/views/booking_view.dart';
import 'package:fptbooking_app/views/room_list_view.dart';
import 'package:fptbooking_app/widgets/app_button.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/app_switch.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';

class RoomCheckingForm extends StatefulWidget {
  final dynamic room;
  final Function enableLoading;
  final Function disableLoading;

  RoomCheckingForm({key, this.room, this.enableLoading, this.disableLoading})
      : super(key: key);

  @override
  _RoomCheckingFormState createState() => _RoomCheckingFormState(
      room: this.room,
      disableLoading: this.disableLoading,
      enableLoading: this.enableLoading);
}

class _RoomCheckingFormState extends State<RoomCheckingForm> {
  static const int SHOWING_VIEW = 1;
  int _state = SHOWING_VIEW;
  dynamic room;

  final Function enableLoading;
  final Function disableLoading;

  _RoomCheckingFormState({this.room, this.enableLoading, this.disableLoading});

  _RoomCheckingFormPresenter _presenter;

  Future<bool> showConfirm() {
    return DialogHelper.showConfirm(context: context);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    _presenter = _RoomCheckingFormPresenter(view: this);
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  void showSuccess() async {
    await DialogHelper.showMessage(
        context: this.context, title: "Message", contents: ["Successful"]);
  }

  void refresh() => setState(() {});

  Widget _buildShowingViewWidget(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            "ROOM CHECKING",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          _getTimeInfo(),
          SimpleInfo(
            labelText: "Status",
            child: AppSwitch(
              value: room["is_available"],
              text: "Available",
              onChanged: _presenter.onStatusChanged,
            ),
          ),
          _getResourcesChecking(),
          SimpleInfo(
            labelText: 'Note',
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: "#CCCCCC".toColor())),
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                maxLines: 7,
                onChanged: _presenter.onNoteChanged,
                initialValue: room["note"] ?? "",
                style: TextStyle(fontSize: 14),
                decoration:
                    InputDecoration.collapsed(hintText: "Write something"),
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
  Widget _getResourcesChecking() {
    var widgets = (room["resources"] as List<dynamic>)
        ?.map((o) => AppSwitch(
              text: o["name"],
              value: o["is_available"],
              onChanged: (val) => _presenter.onResourceStatusChanged(val, o),
            ))
        ?.toList();
    return SimpleInfo(
      labelText: "Resources",
      child: widgets != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            )
          : Text("Nothing"),
    );
  }

  Widget _getTimeInfo() {
    var timeStr =
        IntlHelper.format(DateTime.now(), formatStr: "dd/MM/yyyy, hh:mm");
    return SimpleInfo(
      labelText: "Current time",
      child: SelectableText(timeStr),
    );
  }
}

class _RoomCheckingFormPresenter {
  _RoomCheckingFormState view;

  _RoomCheckingFormPresenter({this.view});

  void onStatusChanged(bool value) {
    view.room["is_available"] = value;
    view.refresh();
  }

  void onNoteChanged(String val) {
    view.room["note"] = val;
  }

  void onSubmit() async {
    var confirmed = await view.showConfirm();
    if (!confirmed) return;
    view.enableLoading();
    var success = false;
    RoomRepo.checkRoomStatus(
            code: view.room["code"],
            data: {
              'note': view.room["note"],
              'is_available': view.room["is_available"],
              'check_resources': view.room["resources"]
            },
            error: view.showError,
            success: () {
              success = true;
              BookingView.needRefresh();
              RoomListView.needRefresh();
              view.disableLoading();
              view.showSuccess();
            },
            invalid: view.showInvalidMessages)
        .whenComplete(() => {
              if (!success) {view.disableLoading()}
            });
  }

  void onResourceStatusChanged(bool val, dynamic res) {
    res["is_available"] = val;
    view.refresh();
  }
}
