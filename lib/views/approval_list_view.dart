import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/app/refreshable.dart';
import 'package:fptbooking_app/contexts/page_context.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/helpers/paging_helper.dart';
import 'package:fptbooking_app/repos/booking_repo.dart';
import 'package:fptbooking_app/storages/memory_storage.dart';
import 'package:fptbooking_app/views/booking_detail_view.dart';
import 'package:fptbooking_app/views/frags/approval_request_table.dart';
import 'package:fptbooking_app/widgets/app_dropdown_button.dart';
import 'package:fptbooking_app/widgets/app_paging.dart';
import 'package:fptbooking_app/widgets/app_scroll.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:provider/provider.dart';

class ApprovalListView extends StatefulWidget {
  ApprovalListView({key}) : super(key: key);

  @override
  _ApprovalListViewState createState() => _ApprovalListViewState();
}

class _ApprovalListViewState extends State<ApprovalListView>
    with Refreshable, AutomaticKeepAliveClientMixin {
  static const int SHOWING_VIEW = 1;
  static const int LOADING_DATA = 2;
  int _state = LOADING_DATA;

  DateTime fromDate = DateTime.now().subtract(Duration(days: 7));
  DateTime toDate = DateTime.now();
  _ApprovalListViewPresenter _presenter;
  List<dynamic> bookings;
  String status = MemoryStorage.statuses[0].key;
  String orderBy = orderByValues[0].key;
  PageContext pageContext;
  int page = 1;
  final int limit = 20;
  int totalCount;
  dynamic searchObj;

  static final List<MapEntry<String, String>> orderByValues = [
    MapEntry("dsent_date", "Latest requested date"),
    MapEntry("abooked_date", "Nearest booked date"),
  ];

  dynamic getSearchObj(int page) {
    return <String, dynamic>{
      'limit': this.limit,
      'toDate': this.toDate,
      'page': page,
      'fromDate': this.fromDate,
      'status': this.status,
      'orderBy': this.orderBy,
    };
  }

  void changePage(int p) {
    setState(() {
      page = p;
    });
  }

  void loadRequestData() {
    setState(() {
      _state = LOADING_DATA;
      bookings = null;
    });
  }

  void changeDateRange(DateTime from, DateTime to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
  }

  void changeStatus(String val) {
    setState(() {
      status = val;
    });
  }

  void changeOrderBy(String val) {
    setState(() {
      orderBy = val;
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

  @override
  void initState() {
    super.initState();
    pageContext = Provider.of<PageContext>(context, listen: false);
    pageContext.setRefreshable(ApprovalListView, this);
    _presenter = _ApprovalListViewPresenter(view: this);
    _presenter.handleInitState(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("build ${this.runtimeType}");
    if (isLoadingData()) {
      return _buildLoadingDataWidget(context);
    }
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  void refreshApprovalListData(List<dynamic> data, int count) {
    setState(() {
      _state = SHOWING_VIEW;
      bookings = data;
      this.totalCount = count;
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

  void refresh<T>({T refreshParam}) {
    this.needRefresh = false;
    _presenter.onRefresh();
  }

  void navigateToBookingDetail(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailView(
          id: id,
          type: BookingDetailView.TYPE_REQUEST_DETAIL,
        ),
      ),
    ).then((value) {
      if (this.needRefresh) {
        refresh();
      }
    });
  }

  //widgets
  Widget _mainView({bool loading = false}) {
    var widgets = <Widget>[
      Container(
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _dateRange(),
            SimpleInfo(
                labelText: "Status",
                child: AppDropdownButton<String>(
                  onChanged: _presenter.onStatusChanged,
                  value: status,
                  items: MemoryStorage.statuses
                      .map((val) => DropdownMenuItem<String>(
                            value: val.key,
                            child: Text(val.value),
                          ))
                      .toList(),
                )),
            SimpleInfo(
                labelText: "Order by",
                child: AppDropdownButton<String>(
                  onChanged: _presenter.onOrderByChanged,
                  value: orderBy,
                  items: orderByValues
                      .map((val) => DropdownMenuItem<String>(
                            value: val.key,
                            child: Text(val.value),
                          ))
                      .toList(),
                )),
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
          ],
        ),
      )
    ];
    if (bookings != null) {
      widgets.addAll([
        Divider(),
        ApprovalRequestTable(
          bookings: bookings,
          onRowTap: _presenter.onRowTap,
          fromDate: fromDate,
          toDate: toDate,
          status: status,
        )
      ]);
      if (bookings.length == 0)
        widgets.add(Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 15),
          child: Text(
            "You have no request",
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
        widgets.add(Container(
          margin: EdgeInsets.all(15),
          child: appPagingWidget,
        ));
      }
    }

    return LoadingModal(
      isLoading: loading,
      child: AppScroll(
        onRefresh: _presenter.onRefresh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
        ),
      ),
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
        labelText: "Requested date range", marginBetween: 0, child: btn);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => !needRefresh;
}

class _ApprovalListViewPresenter {
  _ApprovalListViewState view;

  _ApprovalListViewPresenter({this.view});

  void handleInitState(BuildContext context) {
    view.searchObj = view.getSearchObj(1);
    _getRequests(view.searchObj);
  }

  bool _validateSearch(dynamic search) {
    if (search['fromDate'].difference(search['toDate']).inDays > 31) {
      view.showInvalidMessages(["Only range in 1 month is allowed"]);
      return false;
    }
    return true;
  }

  Future<void> onRefresh() async {
    if (view.searchObj != null) this.onSearchPressed(view.searchObj);
  }

  void onPagePressed(int page) {
    view.changePage(page);
    onSearchPressed(view.getSearchObj(page));
  }

  void onStatusChanged(String status) {
    view.changeStatus(status);
  }

  void onSearchPressed(dynamic search) {
    if (!_validateSearch(search)) return;
    view.loadRequestData();
    _getRequests(search);
  }

  void onOrderByChanged(String orderBy) {
    view.changeOrderBy(orderBy);
  }

  Future<void> _getRequests(dynamic search) {
    var success = false;
    view.searchObj = search;
    view.page = search['page'];
    return BookingRepo.getManagedRequest(
        fields: "info,room,member",
        fromDateStr: IntlHelper.format(search['fromDate']),
        toDateStr: IntlHelper.format(search['toDate']),
        status: search['status'],
        page: search['page'],
        limit: search['limit'],
        sorts: search['orderBy'],
        error: view.showError,
        invalid: view.showInvalidMessages,
        success: (data, totalCount) {
          success = true;
          view.refreshApprovalListData(data, totalCount);
        }).whenComplete(() {
      if (!success) view.setShowingViewState();
    });
  }

  void onDateRangePressed() async {
    var picked = await view.showDateRangePicker();
    if (picked != null && picked.length == 2) {
      view.changeDateRange(picked[0], picked[1]);
    }
  }

  void onRowTap(dynamic data) {
    int id = data["id"];
    print(id);
    view.navigateToBookingDetail(id);
  }
}
