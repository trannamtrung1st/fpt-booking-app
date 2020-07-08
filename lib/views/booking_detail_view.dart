import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/repos/booking_repo.dart';
import 'package:fptbooking_app/repos/room_repo.dart';
import 'package:fptbooking_app/views/dialogs/change_room_dialog.dart';
import 'package:fptbooking_app/views/frags/booking_detail_form.dart';
import 'package:fptbooking_app/widgets/app_button.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/app_scroll.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';

class BookingDetailView extends StatefulWidget {
  final int id;
  static const TYPE_CALENDAR_DETAIL = 1;
  static const TYPE_REQUEST_DETAIL = 2;
  final int type;

  BookingDetailView({key, this.id, this.type}) : super(key: key);

  @override
  _BookingDetailViewState createState() =>
      _BookingDetailViewState(id: id, type: this.type);
}

class _BookingDetailViewState extends State<BookingDetailView> {
  static const int SHOWING_VIEW = 1;
  static const int LOADING_DATA = 2;
  int _state = LOADING_DATA;
  int id;
  final int type;
  dynamic data;
  bool _dataUpdated = false;

  _BookingDetailViewState({@required this.id, this.type});

  _BookingDetailViewPresenter _presenter;

  void updateData() {
    setState(() {
      _dataUpdated = true;
    });
  }

  void showEmptyRoomNotAllowedMessage() {
    DialogHelper.showMessage(
        context: context, contents: ["Booking request must have room"]);
  }

  void showChangeRoomDialog() {
    DialogHelper.showCustomModalBottomSheet<void>(
        context: context,
        builder: (context) => ChangeRoomDialog(
              currentRoom: data["room"],
              onCancelPressed: _presenter.onChangeRoomCancelPressed,
              onRoomTextChanged: null,
              onUpdatePressed: _presenter.onChangeRoomUpdatePressed,
            ));
  }

  void closeRoomDialog() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _presenter = _BookingDetailViewPresenter(view: this);
    _presenter.handleInitState(context);
  }

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    if (isLoadingData()) {
      return _buildLoadingDataWidget(context);
    }
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void loadBookingData(dynamic val) {
    setState(() {
      _state = SHOWING_VIEW;
      data = val;
    });
  }

  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  Widget _buildShowingViewWidget(BuildContext context) {
    if (data == null) return _mainContent(body: Container());
    var widgets = <Widget>[];
    switch (type) {
      case BookingDetailView.TYPE_CALENDAR_DETAIL:
        widgets.add(_calendarDetail());
        break;
      case BookingDetailView.TYPE_REQUEST_DETAIL:
        widgets.addAll(<Widget>[_requestDetail(), _approvalForm()]);
        break;
    }
    return _mainContent(
        body: AppScroll(
      onRefresh: _presenter.onRefresh,
      padding: EdgeInsets.all(15),
      child: Column(
        children: widgets,
      ),
    ));
  }

  //isLoadingData
  bool isLoadingData() => _state == LOADING_DATA;

  void setLoadingDataState() => setState(() {
        _state = LOADING_DATA;
      });

  Widget _buildLoadingDataWidget(BuildContext context) {
    return _mainContent(
        body: LoadingModal(
      child: Container(),
      isLoading: true,
    ));
  }

  void showInvalidMessages(List<String> mess) {
    DialogHelper.showMessage(
        context: context,
        title: "Sorry",
        contents: mess,
        onOk: () {
          navigateBack();
          return true;
        });
  }

  void navigateBack() {
    Navigator.of(context).pop();
  }

  void showError() {
    DialogHelper.showUnknownError(
        context: this.context,
        onOk: () {
          navigateBack();
          return true;
        });
  }

  //widgets
  Widget _mainContent({@required Widget body}) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            appBar: ViewHelper.getDefaultAppBar(title: _getAppBarTitle()),
            body: body));
  }

  String _getAppBarTitle() {
    switch (type) {
      case BookingDetailView.TYPE_CALENDAR_DETAIL:
        return "Calendar detail";
      case BookingDetailView.TYPE_REQUEST_DETAIL:
        return "Request detail";
    }
    throw Exception("Invalid type");
  }

  Widget _approvalForm() {
    return AppCard(
      margin: EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            "APPROVAL SECTION",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SimpleInfo(
            labelText: 'Message',
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: "#CCCCCC".toColor())),
              padding: EdgeInsets.all(8.0),
              //Bugs when using Vietnamese language, related: https://github.com/flutter/flutter/issues/53086
              child: TextFormField(
                maxLines: 7,
                onChanged: _presenter.onManagerMessageChanged,
                initialValue: data["manager_message"] ?? "",
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration.collapsed(
                    hintText: "Enter your message here"),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              AppButton(
                child: Text("DENY"),
                type: "danger",
                onPressed: _presenter.onDenyPressed,
              ),
              Spacer(),
              AppButton(
                child: Text("APPROVE"),
                type: "success",
                onPressed: _presenter.onApprovePressed,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _calendarDetail() {
    var ops = <Widget>[
      Spacer(),
    ];
    var now = DateTime.now();
    var startTime = IntlHelper.parseDateTime(data["start_time"]["display"]);
    var finishTime = IntlHelper.parseDateTime(data["finish_time"]["display"]);
    var allowFeedbackTime = finishTime.add(Duration(hours: 4));
    if (data["status"] == 'Approved' &&
        now.compareTo(finishTime) >= 0 &&
        now.compareTo(allowFeedbackTime) < 0)
      ops.add(
        AppButton(
          type: "success",
          child: Text('FEEDBACK'),
          onPressed: () {},
        ),
      );
    if (data["status"] == 'Processing' ||
        data["status"] == 'Valid' && now.compareTo(startTime) < 0)
      ops.insert(
        0,
        AppButton(
          type: "danger",
          child: Text('ABORT'),
          onPressed: () {},
        ),
      );
    return BookingDetailForm(
      data: data,
      feedbackWidget: SimpleInfo(
        labelText: 'Feedback',
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(color: "#CCCCCC".toColor())),
          padding: EdgeInsets.all(8.0),
          //Bugs when using Vietnamese language, related: https://github.com/flutter/flutter/issues/53086
          child: TextFormField(
            maxLines: 7,
            onChanged: _presenter.onFeedbackChanged,
            initialValue: data["feedback"] ?? "",
            style: TextStyle(fontSize: 14),
            decoration:
                InputDecoration.collapsed(hintText: "Enter your text here"),
          ),
        ),
      ),
      managerMessage: SimpleInfo(
        labelText: 'Manager message',
        child: Text(data["manager_message"] ?? ""),
      ),
      operations: <Widget>[
        Divider(),
        Row(
          children: ops,
        )
      ],
    );
  }

  Widget _requestDetail() {
    return BookingDetailForm(
      feedbackWidget: SimpleInfo(
        labelText: "Feedback",
        child: Text(data["feedback"] ?? ""),
      ),
      data: data,
      changeRoomBtn: GestureDetector(
        onTap: _presenter.onChangeRoomPressed,
        child: Container(
          margin: EdgeInsets.only(left: 10),
          child: Text(
            "change",
            style: TextStyle(
                decoration: TextDecoration.underline, color: Colors.grey),
          ),
        ),
      ),
      onRemoveService: _presenter.onRemoveService,
      operations: !_dataUpdated
          ? null
          : <Widget>[
              Divider(),
              Row(
                children: <Widget>[
                  Spacer(),
                  AppButton(
                    child: (Text("UPDATE")),
                    onPressed: _presenter.onManagerUpdateRequestPressed,
                    type: "success",
                  )
                ],
              )
            ],
    );
  }
}

class _BookingDetailViewPresenter {
  _BookingDetailViewState view;

  _BookingDetailViewPresenter({this.view});

  void handleInitState(BuildContext context) {
    _getBookingDetail(view.id);
  }

  Future<void> onRefresh() {
    return _getBookingDetail(view.id);
  }

  void onManagerUpdateRequestPressed() {}

  void onRemoveService(dynamic data) {
    var services = view.data["attached_services"] as List<dynamic>;
    services.removeWhere((element) => element["code"] == data["code"]);
    view.updateData();
  }

  void onDenyPressed() {}

  void onApprovePressed() {}

  void onManagerMessageChanged(String value) {
    view.data["manager_message"] = value;
  }

  void onFeedbackChanged(String value) {
    view.data["feedback"] = value;
  }

  void onChangeRoomPressed() {
    view.showChangeRoomDialog();
  }

  void onChangeRoomCancelPressed(String text) {
    view.closeRoomDialog();
  }

  void onChangeRoomUpdatePressed(String text) {
    if (text.isEmpty) {
      view.showEmptyRoomNotAllowedMessage();
      return;
    }
    view.closeRoomDialog();
    view.data["room"] = {"code": text};
    view.updateData();
  }

  Future<void> _getBookingDetail(int id) {
    var success = false;
    return BookingRepo.getDetail(
        id: id,
        dateFormat: "dd/MM/yyyy",
        error: view.showError,
        invalid: view.showInvalidMessages,
        success: (val) {
          success = true;
          view.loadBookingData(val);
        }).whenComplete(() => {if (!success) view.setShowingViewState()});
  }
}
