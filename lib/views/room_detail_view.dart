import 'package:flutter/material.dart';
import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:fptbooking_app/contexts/page_context.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/helpers/paging_helper.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/repos/booking_repo.dart';
import 'package:fptbooking_app/repos/room_repo.dart';
import 'package:fptbooking_app/views/booking_view.dart';
import 'package:fptbooking_app/views/frags/booking_form.dart';
import 'package:fptbooking_app/views/frags/role_checking_form.dart';
import 'package:fptbooking_app/views/frags/room_booking_table.dart';
import 'package:fptbooking_app/views/frags/room_info_card.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/app_paging.dart';
import 'package:fptbooking_app/widgets/app_scroll.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:fptbooking_app/widgets/tag.dart';
import 'package:fptbooking_app/widgets/tags_container.dart';
import 'package:provider/provider.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

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
  DateTime fromDate = DateTime.now().subtract(Duration(days: 7));
  DateTime toDate = DateTime.now();
  int type;
  List<dynamic> bookings;

  int page = 1;
  final int limit = 10;
  int totalCount;
  dynamic searchObj;

  void loadBookingData() {
    setState(() {
      _state = PROCESS_DATA;
      bookings = null;
    });
  }

  void changePage(int p) {
    setState(() {
      page = p;
    });
  }

  void refreshRoomBookingData(List<dynamic> data, int count) {
    setState(() {
      _state = SHOWING_VIEW;
      bookings = data;
      this.totalCount = count;
    });
  }

  void changeDateRange(DateTime from, DateTime to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
  }

  Future<List<DateTime>> showDateRangePicker() async {
    var now = new DateTime.now();
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
        context: context,
        initialFirstDate: now,
        initialLastDate: now,
        firstDate: new DateTime(now.year - 1),
        lastDate: new DateTime(now.year + 1));
    return picked;
  }

  dynamic getSearchObj(int page) {
    return <String, dynamic>{
      'limit': this.limit,
      'toDate': this.toDate,
      'page': page,
      'fromDate': this.fromDate,
      'orderBy': 'dbooked_date',
    };
  }

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
      case RoomDetailView.TYPE_ROOM_INFO:
        if (loginContext.isRoomChecker() &&
            type == RoomDetailView.TYPE_ROOM_INFO &&
            data["checker_valid"] == true)
          widgets.add(RoomCheckingForm(
            room: data,
            enableLoading: this.setProcessDataState,
            disableLoading: this.setShowingViewState,
          ));
        var rBookingWidgets = [
          Text(
            "ROOM BOOKINGS",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          _dateRange(),
          Row(
            children: <Widget>[
              Spacer(),
              ButtonTheme(
                minWidth: 0,
                height: 40,
                buttonColor: Colors.orange,
                child: RaisedButton(
                    onPressed: () {
                      var searchObj = getSearchObj(1);
                      _presenter.onSearchPressed(searchObj);
                    },
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                    )),
              )
            ],
          )
        ];
        if (bookings != null) {
          rBookingWidgets.addAll([
            Divider(),
            RoomBookingTable(
              roomCode: code,
              bookings: bookings,
//              onRowTap: _presenter.onRowTap,
              fromDate: fromDate,
              toDate: toDate,
              status: "",
            )
          ]);
          if (bookings.length == 0)
            rBookingWidgets.add(Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 15),
              child: Text(
                "This room has no booking",
                textAlign: TextAlign.center,
              ),
            ));
          else {
            var paging = Paging()
              ..currentPage = page
              ..itemsPerPage = limit
              ..pagesPerLoad = 5;
            paging.countPage(totalCount);
            var appPagingWidget = AppPaging(
              onPagePressed: _presenter.onPagePressed,
              paging: paging,
            );
            rBookingWidgets.add(Container(
              margin: EdgeInsets.all(15),
              child: appPagingWidget,
            ));
          }
        }
        widgets.add(AppCard(
          margin: EdgeInsets.only(top: 15),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rBookingWidgets),
        ));
        break;
    }

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

  Widget _dateRange() {
    var text = IntlHelper.format(fromDate) + " - " + IntlHelper.format(toDate);
    Widget btn = MaterialButton(
      onPressed: _presenter.onDateRangePressed,
      minWidth: 0,
      height: 0,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.fromLTRB(0, 7, 7, 7),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
    );
    return SimpleInfo(
        labelText: "Booked date range", marginBetween: 0, child: btn);
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
    var location = data.containsKey("block") && data["block"] != null
        ? (data["block"]["name"] + " - " + data["level"]["name"])
        : "Not set";
    var activeTime =
        data.containsKey("active_from_time") && data["active_from_time"] != null
            ? (data["active_from_time"] + " - " + data["active_to_time"])
            : "Not set";
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
          labelText: "Active time",
          child: SelectableText(activeTime),
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
    if (!hanging) {
      view.searchObj = view.getSearchObj(1);
      _getBookings(view.searchObj);
    }
  }

  void onPagePressed(int page) {
    view.changePage(page);
    onSearchPressed(view.getSearchObj(page));
  }

  void onSearchPressed(dynamic search) {
    if (!_validateSearch(search)) return;
    view.loadBookingData();
    _getBookings(search);
  }

  Future<void> _getBookings(dynamic search) {
    var success = false;
    view.searchObj = search;
    view.page = search['page'];
    return BookingRepo.getRoomBookings(
        fields: "info,room,member",
        fromDateStr: IntlHelper.format(search['fromDate']),
        toDateStr: IntlHelper.format(search['toDate']),
        status: search['status'],
        page: search['page'],
        roomCode: view.code,
        limit: search['limit'],
        sorts: search['orderBy'],
        error: view.showError,
        invalid: view.showInvalidMessages,
        success: (data, totalCount) {
          success = true;
          view.refreshRoomBookingData(data, totalCount);
        }).whenComplete(() {
      if (!success) view.setShowingViewState();
    });
  }

  bool _validateSearch(dynamic search) {
    if (search['fromDate'].difference(search['toDate']).inDays > 31) {
      view.showInvalidMessages(["Only range in 1 month is allowed"]);
      return false;
    }
    return true;
  }

  void onDateRangePressed() async {
    var picked = await view.showDateRangePicker();
    if (picked != null && picked.length == 2) {
      view.changeDateRange(picked[0], picked[1]);
    }
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
