import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/app/refreshable.dart';
import 'package:fptbooking_app/contexts/page_context.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/paging_helper.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/repos/booking_repo.dart';
import 'package:fptbooking_app/storages/memory_storage.dart';
import 'package:fptbooking_app/views/booking_detail_view.dart';
import 'package:fptbooking_app/views/frags/booking_info_card.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/app_dropdown_button.dart';
import 'package:fptbooking_app/widgets/app_paging.dart';
import 'package:fptbooking_app/widgets/app_scroll.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:provider/provider.dart';

class BookingListView extends StatefulWidget {
  BookingListView({key}) : super(key: key);

  @override
  _BookingListViewState createState() => _BookingListViewState();
}

class _BookingListViewState extends State<BookingListView>
    with Refreshable, AutomaticKeepAliveClientMixin {
  static const int SHOWING_VIEW = 1;
  static const int LOADING_DATA = 2;
  int _state = LOADING_DATA;
  int page = 1;
  int limit = 10;
  int totalCount;
  dynamic searchObj;

  _BookingListViewPresenter _presenter;
  List<dynamic> groups;
  final GlobalKey bookingCardsKey = GlobalKey(debugLabel: "_bookingCardsKey");
  String searchValue = '';
  String status = MemoryStorage.statuses[0].key;
  PageContext pageContext;

  dynamic getSearchObj(int page) {
    return <String, dynamic>{
      'limit': this.limit,
      'searchValue': this.searchValue,
      'status': this.status,
      'page': page,
    };
  }

  void refresh<T>({T refreshParam}) {
    this.needRefresh = false;
    setState(() {
      this.groups = null;
      _presenter.onRefresh();
    });
  }

  void changePage(int p) {
    setState(() {
      page = p;
      refresh();
    });
  }

  void changeStatus(String val) {
    setState(() {
      status = val;
    });
  }

  void navigateToBookingDetail(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailView(
          id: id,
          type: BookingDetailView.TYPE_BOOKING_DETAIL,
        ),
      ),
    ).then((value) {
      if (this.needRefresh) refresh();
    });
  }

  @override
  void initState() {
    super.initState();
    pageContext = Provider.of<PageContext>(context, listen: false);
    pageContext.setRefreshable(BookingListView, this);
    _presenter = _BookingListViewPresenter(view: this);
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

  void refreshBookingData(List<dynamic> data, int count) {
    setState(() {
      _state = SHOWING_VIEW;
      groups = data;
      totalCount = count;
    });
  }

  void loadBookingData() {
    setState(() {
      _state = LOADING_DATA;
      groups = null;
    });
  }

  Widget _buildShowingViewWidget(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), child: _mainView());
  }

  //isLoadingData
  bool isLoadingData() => _state == LOADING_DATA;

  Widget _buildLoadingDataWidget(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _mainView(loading: true));
  }

  void showInvalidMessages(List<String> mess) {
    DialogHelper.showMessage(context: context, title: "Sorry", contents: mess);
  }

  void showError() {
    DialogHelper.showUnknownError(context: this.context);
  }

  //widgets
  Widget _mainView({bool loading = false}) {
    var widgets = <Widget>[
      Container(
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _filterWidgets(),
        ),
      ),
    ];
    if (groups != null) widgets.add(_getBookingsCard());
    return Scaffold(
        appBar: ViewHelper.getStackAppBar(title: "Booking history"),
        body: LoadingModal(
            isLoading: loading,
            child: AppScroll(
              onRefresh: _presenter.onRefresh,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widgets),
            )));
  }

  List<Widget> _filterWidgets() {
    var widgets = <Widget>[
      SimpleInfo(
        labelText: "Search bookings",
        containerMargin: EdgeInsets.only(bottom: 14),
        child: TextFormField(
          autofocus: false,
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: 14),
          onChanged: (value) => searchValue = value,
          decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: "#CCCCCC".toColor())),
              hintText: "Input something: booking's code, ...",
              contentPadding: EdgeInsets.only(bottom: 7),
              isDense: true),
        ),
      ),
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
      Row(
        children: <Widget>[
          Spacer(),
          ButtonTheme(
            minWidth: 0,
            height: 40,
            buttonColor: Colors.orange,
            child: RaisedButton(
                onPressed: () {
                  _presenter.onSearchPressed(getSearchObj(1));
                },
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                )),
          )
        ],
      ),
    ];
    return widgets;
  }

  Widget _getBookingsCard() {
    var lastSearched = searchObj['searchValue'];
    var searchStr = lastSearched.isNotEmpty ? "for \"$lastSearched\", " : "";
    var sStr = status.isEmpty ? "All" : status;
    var text = groups.length > 0
        ? Text("Bookings " + searchStr + "status \"$sStr\"")
        : Text("You have no bookings " + searchStr + "status \"$sStr\"");
    var cardWidgets = <Widget>[text];
    var card = AppCard(
      key: bookingCardsKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cardWidgets,
      ),
    );

    for (dynamic group in groups) {
      var date = group[0]["group_by_date_key"];
      cardWidgets.add(AppCard(
        color: Colors.orangeAccent,
        margin: EdgeInsets.only(top: 10),
        child: Text(
          date,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ));
      for (dynamic o in group)
        cardWidgets.add(BookingInfoCard(
          margin: EdgeInsets.zero,
          onBookingPressed: (val) => _presenter.onBookingPressed(val),
          booking: o,
        ));
    }
    if (groups.length > 0) {
      var paging = Paging()
        ..currentPage = page
        ..itemsPerPage = limit
        ..pagesPerLoad = 5;
      paging.countPage(totalCount);
      var appPagingWidget = AppPaging(
        onPagePressed: _presenter.onPagePressed,
        paging: paging,
      );
      cardWidgets.add(Container(
        margin: EdgeInsets.only(top: 15),
        child: appPagingWidget,
      ));
    }
    return card;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => !needRefresh;
}

class _BookingListViewPresenter {
  _BookingListViewState view;

  _BookingListViewPresenter({this.view});

  void handleInitState(BuildContext context) {
    view.searchObj = view.getSearchObj(1);
    _getBookingsGroupByDate(view.searchObj);
  }

  Future<void> onRefresh() {
    if (view.searchObj != null) return onSearchPressed(view.searchObj);
    return null;
  }

  void onPagePressed(int page) {
    view.changePage(page);
  }

  void onBookingPressed(dynamic data) {
    int id = data["id"];
    print(id);
    view.navigateToBookingDetail(id);
  }

  void onStatusChanged(String status) {
    view.changeStatus(status);
  }

  Future<void> onSearchPressed(dynamic search) {
    view.loadBookingData();
    return _getBookingsGroupByDate(search);
  }

  Future<void> _getBookingsGroupByDate(dynamic search) {
    view.searchObj = search;
    view.page = search['page'];
    var success = false;
    return BookingRepo.getOwner(
        fields: "info,room,member",
        groupBy: 'date',
        sorts: "dsent_date",
        limit: search['limit'],
        page: search['page'],
        search: search['searchValue'],
        status: search['status'],
        invalid: view.showInvalidMessages,
        error: view.showError,
        success: (data, count) {
          success = true;
          view.refreshBookingData(data, count);
        }).whenComplete(() {
      if (!success) view.setShowingViewState();
    });
  }
}
