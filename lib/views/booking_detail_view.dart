import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/contexts/page_context.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/repos/booking_repo.dart';
import 'package:fptbooking_app/views/approval_list_view.dart';
import 'package:fptbooking_app/views/booking_list_view.dart';
import 'package:fptbooking_app/views/booking_view.dart';
import 'package:fptbooking_app/views/calendar_view.dart';
import 'package:fptbooking_app/views/dialogs/change_room_dialog.dart';
import 'package:fptbooking_app/views/frags/booking_detail_form.dart';
import 'package:fptbooking_app/widgets/app_button.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/app_scroll.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:provider/provider.dart';

class BookingDetailView extends StatefulWidget {
  final int id;
  static const TYPE_BOOKING_DETAIL = 0;
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
  static const int UPDATE_DATA = 3;
  int _state = LOADING_DATA;
  int id;
  final int type;
  dynamic data;
  bool dataUpdated = false;
  LoginContext loginContext;
  PageContext pageContext;

  _BookingDetailViewState({@required this.id, this.type});

  _BookingDetailViewPresenter _presenter;

  void updateData() {
    setState(() {
      dataUpdated = true;
    });
  }

  void showSuccess() async {
    await DialogHelper.showMessage(
        context: this.context, title: "Message", contents: ["Successful"]);
  }

  void showEmptyRoomNotAllowedMessage() {
    DialogHelper.showMessage(
        context: context, contents: ["Booking request must have room"]);
  }

  Future<bool> showConfirm() {
    return DialogHelper.showConfirm(context: context);
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
    loginContext = Provider.of<LoginContext>(context, listen: false);
    pageContext = Provider.of<PageContext>(context, listen: false);
    _presenter = _BookingDetailViewPresenter(view: this);
    _presenter.handleInitState(context);
  }

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    if (isLoadingData()) {
      return _buildLoadingDataWidget(context);
    }
    if (isUpdateData()) {
      return _buildUpdateDataWidget(context);
    }
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void loadBookingData(dynamic val) {
    setState(() {
      _state = SHOWING_VIEW;
      data = val;
      dataUpdated = false;
    });
  }

  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  Widget _getShowingViewBody() {
    var widgets = <Widget>[];
    bool processAllowed = false;
    switch (type) {
      case BookingDetailView.TYPE_BOOKING_DETAIL:
      case BookingDetailView.TYPE_CALENDAR_DETAIL:
        widgets.add(_bookingDetail());
        break;
      case BookingDetailView.TYPE_REQUEST_DETAIL:
        processAllowed = (data["status"] == "Processing" &&
                data["manager_type"] == "Department") ||
            (data["status"] == "Valid" && data["manager_type"] == "Area");
        widgets.add(_requestDetail(processAllowed));
        widgets.add(_approvalForm(processAllowed));
        break;
    }
    var body = AppScroll(
      onRefresh: _presenter.onRefresh,
      padding: EdgeInsets.all(15),
      child: Column(
        children: widgets,
      ),
    );
    return body;
  }

  Widget _buildShowingViewWidget(BuildContext context) {
    if (data == null) return _mainContent(body: Container());
    var body = _getShowingViewBody();
    return LoadingModal(
      child: _mainContent(body: body),
      isLoading: false,
    );
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

  //isUpdateData
  bool isUpdateData() => _state == UPDATE_DATA;

  void setUpdateDataState() => setState(() {
        _state = UPDATE_DATA;
      });

  Widget _buildUpdateDataWidget(BuildContext context) {
    var body = _getShowingViewBody();
    return LoadingModal(
      child: _mainContent(body: body),
      isLoading: true,
    );
  }

  void showInvalidMessages(List<String> mess) {
    DialogHelper.showMessage(context: context, title: "Sorry", contents: mess);
  }

  void navigateBack() {
    Navigator.of(context).pop();
  }

  void showError() {
    DialogHelper.showUnknownError(context: this.context);
  }

  //widgets
  Widget _mainContent({@required Widget body}) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            appBar: ViewHelper.getStackAppBar(title: _getAppBarTitle()),
            body: body));
  }

  String _getAppBarTitle() {
    switch (type) {
      case BookingDetailView.TYPE_CALENDAR_DETAIL:
        return "Calendar detail";
      case BookingDetailView.TYPE_BOOKING_DETAIL:
        return "Booking detail";
      case BookingDetailView.TYPE_REQUEST_DETAIL:
        return "Request detail";
    }
    throw Exception("Invalid type");
  }

  Widget _approvalForm(bool processAllowed) {
    var widgets = <Widget>[
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
            readOnly: !processAllowed,
            maxLines: 7,
            onChanged: _presenter.onManagerMessageChanged,
            initialValue: data["manager_message"] ?? "",
            style: TextStyle(fontSize: 14),
            decoration:
                InputDecoration.collapsed(hintText: "Enter your message here"),
          ),
        ),
      ),
    ];
    if (processAllowed)
      widgets.add(Row(
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
      ));
    return AppCard(
      margin: EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgets,
      ),
    );
  }

  Widget _bookingDetail() {
    var ops = <Widget>[
      Spacer(),
    ];
    var now = DateTime.now();
    var startTime = IntlHelper.parseDateTime(data["start_time"]["display"]);
    var finishTime = IntlHelper.parseDateTime(data["finish_time"]["display"]);
    var allowFeedbackTime = finishTime.add(Duration(hours: 4));
    if (loginContext.tokenData["user_id"] == data["book_member_id"]) {
      if (data["status"] == 'Approved' &&
          now.compareTo(finishTime) >= 0 &&
          now.compareTo(allowFeedbackTime) < 0)
        ops.add(
          AppButton(
            type: "success",
            child: Text('FEEDBACK'),
            onPressed: _presenter.onFeedbackPressed,
          ),
        );
      if ((data["status"] == 'Processing' ||
              data["status"] == 'Valid' ||
              data["status"] == 'Approved') &&
          now.compareTo(startTime) < 0)
        ops.insert(
          0,
          AppButton(
            type: "danger",
            child: Text('ABORT'),
            onPressed: _presenter.onAbortPressed,
          ),
        );
    }
    var feedbackEnabled = ops.length > 1;
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
            readOnly: !feedbackEnabled,
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
        child: SelectableText((data["manager_message"]?.isEmpty == true
                ? "Nothing"
                : data["manager_message"]) ??
            "Nothing"),
      ),
      operations: <Widget>[
        Divider(),
        Row(
          children: ops,
        )
      ],
    );
  }

  Widget _requestDetail(bool processAllowed) {
    return BookingDetailForm(
      feedbackWidget: SimpleInfo(
        labelText: "Feedback",
        child: SelectableText((data["feedback"]?.isEmpty == true
                ? "Nothing"
                : data["feedback"]) ??
            "Nothing"),
      ),
      data: data,
      changeRoomBtn: !processAllowed
          ? null
          : GestureDetector(
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
      onRemoveService: !processAllowed ? null : _presenter.onRemoveService,
      operations: !dataUpdated
          ? null
          : <Widget>[
              Divider(),
              Row(
                children: <Widget>[
                  Spacer(),
                  AppButton(
                    child: (Text("UPDATE")),
                    onPressed: _presenter.onUpdateBookingPressed,
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
  LoginContext _loginContext;

  _BookingDetailViewPresenter({this.view}) {
    _loginContext = view.loginContext;
  }

  void handleInitState(BuildContext context) {
    _getBookingDetail(view.id);
  }

  Future<void> onRefresh() {
    return _getBookingDetail(view.id);
  }

  void onRemoveService(dynamic data) {
    var services = view.data["attached_services"] as List<dynamic>;
    services.removeWhere((element) => element["code"] == data["code"]);
    if (!view.data.containsKey("removed_service_ids"))
      view.data["removed_service_ids"] = <int>[];
    var rmServices = view.data["removed_service_ids"];
    rmServices.add(data["id"]);
    view.updateData();
  }

  void onDenyPressed() async {
    var confirmed = await view.showConfirm();
    if (!confirmed) return;
    view.setUpdateDataState();
    var success = false;
    BookingRepo.changeApprovalStatusOfBooking(
            id: view.id,
            model: {
              "is_approved": false,
              "manager_message": view.data["manager_message"]
            },
            error: view.showError,
            success: () {
              success = true;
              view.pageContext.markAsNeedRefresh(BookingView);
              view.pageContext.markAsNeedRefresh(CalendarView);
              view.pageContext.markAsNeedRefresh(ApprovalListView);
              _getBookingDetail(view.id);
            },
            invalid: view.showInvalidMessages)
        .whenComplete(() => {
              if (!success) {view.setShowingViewState()}
            });
  }

  void onApprovePressed() async {
    var confirmed = await view.showConfirm();
    if (!confirmed) return;
    view.setUpdateDataState();
    var success = false;
    BookingRepo.changeApprovalStatusOfBooking(
            id: view.id,
            model: {
              "is_approved": true,
              "manager_message": view.data["manager_message"]
            },
            error: view.showError,
            success: () {
              success = true;
              view.pageContext.markAsNeedRefresh(BookingView);
              view.pageContext.markAsNeedRefresh(CalendarView);
              view.pageContext.markAsNeedRefresh(ApprovalListView);
              _getBookingDetail(view.id);
            },
            invalid: view.showInvalidMessages)
        .whenComplete(() => {
              if (!success) {view.setShowingViewState()}
            });
  }

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

  void onUpdateBookingPressed() async {
    var confirmed = await view.showConfirm();
    if (!confirmed) return;
    view.setUpdateDataState();
    var success = false;
    BookingRepo.updateBooking(
            id: view.id,
            model: {
              'room_code': view.data["room"]["code"],
              'removed_service_ids': view.data["removed_service_ids"]
            },
            error: view.showError,
            success: () {
              success = true;
              view.pageContext.markAsNeedRefresh(BookingView);
              view.pageContext.markAsNeedRefresh(CalendarView);
              view.pageContext.markAsNeedRefresh(ApprovalListView);
              _getBookingDetail(view.id);
              view.showSuccess();
            },
            invalid: view.showInvalidMessages)
        .whenComplete(() => {
              if (!success) {view.setShowingViewState()}
            });
  }

  void onFeedbackPressed() async {
    var confirmed = await view.showConfirm();
    if (!confirmed) return;
    view.setUpdateDataState();
    var success = false;
    BookingRepo.feedbackBooking(
            id: view.id,
            model: {"feedback": view.data["feedback"]},
            error: view.showError,
            success: () {
              success = true;
              view.pageContext.markAsNeedRefresh(BookingView);
              view.pageContext.markAsNeedRefresh(CalendarView);
              view.pageContext.markAsNeedRefresh(ApprovalListView);
              view.pageContext.markAsNeedRefresh(BookingListView);
              _getBookingDetail(view.id);
            },
            invalid: view.showInvalidMessages)
        .whenComplete(() => {
              if (!success) {view.setShowingViewState()}
            });
  }

  void onAbortPressed() async {
    var mess = <String>[];
    if (view.data["feedback"] == null || view.data["feedback"].isEmpty)
      mess.add("You must provide a reason in feedback");
    if (mess.length > 0) {
      view.showInvalidMessages(mess);
      return;
    }
    var confirmed = await view.showConfirm();
    if (!confirmed) return;
    view.setUpdateDataState();
    var success = false;
    BookingRepo.abortBooking(
            id: view.id,
            model: {"feedback": view.data["feedback"]},
            error: view.showError,
            success: () {
              success = true;
              view.pageContext.markAsNeedRefresh(BookingView);
              view.pageContext.markAsNeedRefresh(CalendarView);
              view.pageContext.markAsNeedRefresh(ApprovalListView);
              view.pageContext.markAsNeedRefresh(BookingListView);
              _getBookingDetail(view.id);
            },
            invalid: view.showInvalidMessages)
        .whenComplete(() => {
              if (!success) {view.setShowingViewState()}
            });
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
        fields: _loginContext.isManager() &&
                view.type == BookingDetailView.TYPE_REQUEST_DETAIL
            ? "manager_type"
            : null,
        id: id,
        dateFormat: "dd/MM/yyyy",
        error: view.showError,
        invalid: view.showInvalidMessages,
        success: (val) {
          success = true;
          view.loadBookingData(val);
        }).whenComplete(() {
      if (!success) view.setShowingViewState();
    });
  }
}
