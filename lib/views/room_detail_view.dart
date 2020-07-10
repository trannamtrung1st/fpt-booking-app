import 'package:flutter/material.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/contexts/page_context.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/repos/room_repo.dart';
import 'package:fptbooking_app/views/booking_view.dart';
import 'package:fptbooking_app/views/frags/booking_form.dart';
import 'package:fptbooking_app/views/frags/role_checking_form.dart';
import 'package:fptbooking_app/views/frags/room_info_card.dart';
import 'package:fptbooking_app/widgets/app_scroll.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:fptbooking_app/widgets/tag.dart';
import 'package:fptbooking_app/widgets/tags_container.dart';
import 'package:provider/provider.dart';

class RoomDetailView extends StatefulWidget {
  static const int TYPE_ROOM_INFO = 1;
  static const int TYPE_BOOKING = 2;
  final String code;
  final int type;
  final dynamic extraData;

  RoomDetailView(
      {key, @required this.code, @required this.type, this.extraData})
      : super(key: key);

  @override
  _RoomDetailViewState createState() => _RoomDetailViewState(
      code: this.code, type: this.type, extraData: this.extraData);
}

class _RoomDetailViewState extends State<RoomDetailView> {
  static const int SHOWING_VIEW = 1;
  static const int LOADING_DATA = 2;
  static const int PROCESS_DATA = 3;
  int _state = LOADING_DATA;
  String code;
  dynamic data;
  dynamic extraData;
  LoginContext loginContext;
  PageContext pageContext;

  int type;

  _RoomDetailViewState(
      {@required this.code, @required this.type, this.extraData});

  _RoomDetailViewPresenter _presenter;

  @override
  void initState() {
    super.initState();
    loginContext = Provider.of<LoginContext>(context, listen: false);
    pageContext = Provider.of<PageContext>(context, listen: false);
    _presenter = _RoomDetailViewPresenter(view: this);
    _presenter.handleInitState(context);
  }

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    if (isLoadingData()) {
      return _buildLoadingDataWidget(context);
    }
    if (isProcessData()) {
      return _buildProcessDataWidget(context);
    }
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void loadRoomData(dynamic val) {
    setState(() {
      _state = SHOWING_VIEW;
      data = val;
    });
  }

  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  Widget _getShowingViewBody() {
    var widgets = <Widget>[
      RoomInfoCard(
        margin: EdgeInsets.zero,
        showStatus: true,
        room: data,
        details: [Divider(), _detailInfo()],
      )
    ];
    switch (type) {
      case RoomDetailView.TYPE_BOOKING:
        widgets.add(BookingForm(
          disableLoading: this.setShowingViewState,
          enableLoading: this.setProcessDataState,
          room: data,
          bookedDate: extraData["bookedDate"],
          fromTime: extraData["fromTime"],
          toTime: extraData["toTime"],
          numOfPeople: extraData["numOfPeople"],
        ));
        break;
    }

    if (loginContext.isRoomChecker() &&
        type == RoomDetailView.TYPE_ROOM_INFO &&
        data["checker_valid"] == true)
      widgets.add(RoomCheckingForm(
        room: data,
        enableLoading: this.setProcessDataState,
        disableLoading: this.setShowingViewState,
      ));

    var body = GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AppScroll(
        onRefresh: _presenter.onRefresh,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          ),
        ),
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

  //isProcessData
  bool isProcessData() => _state == PROCESS_DATA;

  void setProcessDataState() => setState(() {
        _state = PROCESS_DATA;
      });

  Widget _buildProcessDataWidget(BuildContext context) {
    var body = _getShowingViewBody();
    return LoadingModal(
      isLoading: true,
      child: _mainContent(body: body),
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
    return Scaffold(
        appBar: ViewHelper.getStackAppBar(title: _getAppBarTitle()),
        body: body);
  }

  String _getAppBarTitle() {
    switch (type) {
      case RoomDetailView.TYPE_BOOKING:
        return "Booking room detail";
    }
    return "Room information";
  }

  Widget _detailInfo() {
    var location = data["block"]["name"] + " - " + data["level"]["name"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SimpleInfo(
          labelText: "Description",
          child: SelectableText(data["description"] ?? "Nothing"),
        ),
        SimpleInfo(
          labelText: "Location",
          child: SelectableText(location),
        ),
        SimpleInfo(
          isHorizontal: true,
          marginBetween: 0,
          labelText: "Area: ",
          child: SelectableText(
            data["area"]["name"],
            style: TextStyle(color: Colors.blue),
          ),
        ),
        _getResourcesTags(),
      ],
    );
  }

  Widget _getResourcesTags() {
    var services = data["resources"] as List<dynamic>;
    Widget widget = Text("Nothing");
    if (services != null) {
      var tags = services.where((e) => e["is_available"]);
      if (tags.isNotEmpty) {
        tags = tags.map((e) => Tag(child: SelectableText(e["name"]))).toList();
        widget = TagsContainer(tags: tags);
      }
    }
    return SimpleInfo(
      labelText: 'Resources',
      child: widget,
    );
  }
}

class _RoomDetailViewPresenter {
  _RoomDetailViewState view;
  LoginContext _loginContext;

  _RoomDetailViewPresenter({this.view}) {
    _loginContext = view.loginContext;
  }

  void handleInitState(BuildContext context) {
    var hanging = view.type == RoomDetailView.TYPE_BOOKING;
    _getRoomDetail(view.code, hanging: hanging);
  }

  Future<void> onRefresh() {
    return _getRoomDetail(view.code, hanging: false);
  }

  Future<void> _getRoomDetail(String code, {bool hanging}) {
    var success = false;
    return RoomRepo.getDetail(
        hanging: hanging,
        checkerValid: _loginContext.isRoomChecker(),
        code: code,
        error: view.showError,
        invalid: view.showInvalidMessages,
        success: (val) {
          success = true;
          view.loadRoomData(val);
        }).whenComplete(() {
      if (!success) view.navigateBack();
    });
  }
}
