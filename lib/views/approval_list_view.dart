import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/app/refreshable.dart';
import 'package:fptbooking_app/contexts/page_context.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/intl_helper.dart';
import 'package:fptbooking_app/repos/booking_repo.dart';
import 'package:fptbooking_app/storages/memory_storage.dart';
import 'package:fptbooking_app/views/booking_detail_view.dart';
import 'package:fptbooking_app/views/frags/approval_request_table.dart';
import 'package:fptbooking_app/widgets/app_dropdown_button.dart';
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

class _ApprovalListViewState extends State<ApprovalListView> with Refreshable {
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

  static final List<MapEntry<String, String>> orderByValues = [
    MapEntry("dsent_date", " Latest requested date"),
    MapEntry("abooked_date", "Nearest booked date"),
  ];

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

  void refreshApprovalListData(List<dynamic> data) {
    setState(() {
      _state = SHOWING_VIEW;
      bookings = data;
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
                onPressed: _presenter.onSearchPressed,
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                )),
          )
        ],
      ),
    ];
    if (bookings != null)
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

    return LoadingModal(
      isLoading: loading,
      child: AppScroll(
        onRefresh: _presenter.onRefresh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widgets),
            ),
          ],
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
      child: SelectableText(
        text,
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
    );
    return SimpleInfo(
        labelText: "Requested date range", marginBetween: 0, child: btn);
  }
}

class _ApprovalListViewPresenter {
  _ApprovalListViewState view;

  _ApprovalListViewPresenter({this.view});

  void handleInitState(BuildContext context) {
    _getRequests();
  }

  Future<void> onRefresh() {
    view.loadRequestData();
    return _getRequests();
  }

  void onStatusChanged(String status) {
    view.changeStatus(status);
  }

  void onSearchPressed() {
    view.loadRequestData();
    _getRequests();
  }

  void onOrderByChanged(String orderBy) {
    view.changeOrderBy(orderBy);
  }

  Future<void> _getRequests() {
    var success = false;
    return BookingRepo.getManagedRequest(
        fields: "info,member",
        fromDateStr: IntlHelper.format(view.fromDate),
        toDateStr: IntlHelper.format(view.toDate),
        status: view.status,
        sorts: view.orderBy,
        error: view.showError,
        invalid: view.showInvalidMessages,
        success: (data) {
          success = true;
          view.refreshApprovalListData(data);
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
