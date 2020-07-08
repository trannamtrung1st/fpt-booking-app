import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/repos/room_repo.dart';
import 'package:fptbooking_app/views/frags/room_info_card.dart';
import 'package:fptbooking_app/views/room_detail_view.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/app_scroll.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';

class RoomListView extends StatefulWidget {
  RoomListView({key}) : super(key: key);

  static void Function() needRefresh = () {};

  @override
  _RoomListViewState createState() => _RoomListViewState();
}

class _RoomListViewState extends State<RoomListView>
    with AutomaticKeepAliveClientMixin {
  static const int SHOWING_VIEW = 1;
  static const int LOADING_DATA = 2;
  int _state = LOADING_DATA;

  _RoomListViewPresenter _presenter;
  List<dynamic> rooms;
  final GlobalKey roomCardsKey = GlobalKey(debugLabel: "_roomCardsKey");
  String searchValue = '';

  void refresh() {
    setState(() {
      this.rooms = null;
      _presenter.onRefresh();
    });
  }

  void navigateToRoomDetail(String code) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomDetailView(
          code: code,
          type: RoomDetailView.TYPE_ROOM_INFO,
        ),
      ),
    ).then((value) {
      if (!_keepAlive)
        refresh();
    });
  }

  @override
  void initState() {
    super.initState();
    _presenter = _RoomListViewPresenter(view: this);
    _presenter.handleInitState(context);
    RoomListView.needRefresh = () {
      _keepAlive = false;
      this.updateKeepAlive();
    };
  }

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    super.build(context);
    if (_keepAlive) {
      _keepAlive = true;
      this.updateKeepAlive();
    }
    if (isLoadingData()) {
      return _buildLoadingDataWidget(context);
    }
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  void refreshRoomData(List<dynamic> data) {
    setState(() {
      _state = SHOWING_VIEW;
      rooms = data;
    });
  }

  void loadRoomData() {
    setState(() {
      _state = LOADING_DATA;
      rooms = null;
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
    if (rooms != null) widgets.add(_getRoomsCard());
    return LoadingModal(
        isLoading: loading,
        child: AppScroll(
          onRefresh: _presenter.onRefresh,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: widgets),
        ));
  }

  List<Widget> _filterWidgets() {
    var widgets = <Widget>[
      SimpleInfo(
        labelText: "Search rooms",
        marginBottom: 14,
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                autofocus: false,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 14),
                onChanged: (value) => searchValue = value,
                decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: "#CCCCCC".toColor())),
                    hintText: "Input something: room's code, name ...",
                    contentPadding: EdgeInsets.only(bottom: 7),
                    isDense: true),
              ),
              flex: 11,
            ),
            Spacer(),
            Expanded(
              flex: 2,
              child: ButtonTheme(
                minWidth: 0,
                height: 40,
                buttonColor: Colors.orange,
                child: RaisedButton(
                    onPressed: _presenter.onSearchPressed,
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                    )),
              ),
            )
          ],
        ),
      ),
    ];
    return widgets;
  }

  Widget _getRoomsCard() {
    var text = Text("All rooms");
    if (searchValue.isNotEmpty)
      text = Text("Search result for \"$searchValue\"");
    var cardWidgets = <Widget>[text];
    var card = AppCard(
      key: roomCardsKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cardWidgets,
      ),
    );

    for (dynamic o in rooms) {
      cardWidgets.add(RoomInfoCard(
        onRoomPressed: (val) => _presenter.onRoomPressed(val),
        room: o,
      ));
    }
    return card;
  }

  bool _keepAlive = true;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => _keepAlive;
}

class _RoomListViewPresenter {
  _RoomListViewState view;

  _RoomListViewPresenter({this.view});

  void handleInitState(BuildContext context) {
    _getRooms(null);
  }

  Future<void> onRefresh() {
    return onSearchPressed();
  }

  void onRoomPressed(dynamic data) {
    String code = data["code"];
    print(code);
    view.navigateToRoomDetail(code);
  }

  Future<void> onSearchPressed() {
    view.loadRoomData();
    return _getRooms(view.searchValue);
  }

  Future<void> _getRooms(String searchVal) {
    var success = false;
    return RoomRepo.getRooms(
        search: searchVal,
        invalid: view.showInvalidMessages,
        error: view.showError,
        success: (data) {
          success = true;
          view.refreshRoomData(data);
        }).whenComplete(() {
      if (!success) view.setShowingViewState();
    });
  }
}
