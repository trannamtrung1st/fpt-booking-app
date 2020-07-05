import 'package:flutter/material.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/repos/room_repo.dart';
import 'package:fptbooking_app/widgets/app_button.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:fptbooking_app/widgets/tags_container.dart';

class RoomDetailView extends StatefulWidget {
  static const int TYPE_BOOKING = 1;
  final String code;
  final int type;

  RoomDetailView({key, @required this.code, @required this.type})
      : super(key: key);

  @override
  _RoomDetailViewState createState() =>
      _RoomDetailViewState(code: this.code, type: this.type);
}

class _RoomDetailViewState extends State<RoomDetailView> {
  static const int SHOWING_VIEW = 1;
  static const int LOADING_DATA = 2;
  int _state = LOADING_DATA;
  String code;
  dynamic _data;

  int type;

  _RoomDetailViewState({@required this.code, @required this.type});

  _RoomDetailViewPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = _RoomDetailViewPresenter(view: this);
    _presenter.handleInitState(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingData()) {
      return _buildLoadingDataWidget(context);
    }
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void loadRoomData(dynamic data) {
    setState(() {
      _state = SHOWING_VIEW;
      _data = data;
    });
  }

  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  Widget _buildShowingViewWidget(BuildContext context) {
    var body = SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(15),
        child: _roomInfoCard(),
      ),
    );
    return _mainContent(body: _data != null ? body : Container());
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
    DialogHelper.showMessage(context: context, title: "Sorry", contents: mess);
  }

  void showError() {
    DialogHelper.showUnknownError(
        context: this.context,
        onOk: () {
          Navigator.of(context).pop();
          return true;
        });
  }

  //widgets
  Widget _mainContent({@required Widget body}) {
    return Scaffold(
        appBar: ViewHelper.getDefaultAppBar(title: _getAppBarTitle()),
        body: body);
  }

  String _getAppBarTitle() {
    switch (type) {
      case RoomDetailView.TYPE_BOOKING:
        return "Booking room detail";
      default:
        throw Exception("Invalid type");
    }
  }

  Widget _roomInfoCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _generalInfo(),
          Divider(),
          _detailInfo(),
        ],
      ),
    );
  }

  Widget _generalInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(right: 20),
          child: Column(
            children: <Widget>[
              Container(
                child: Icon(
                  Icons.school,
                  size: 45,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(7),
                margin: EdgeInsets.only(bottom: 7),
                decoration: BoxDecoration(
                    color: Colors.deepOrangeAccent, shape: BoxShape.circle),
              ),
              Text(
                "EMPTY",
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                text: _data["code"],
                style: TextStyle(fontSize: 17, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                      text: "   " + _data["room_type"]["name"],
                      style: TextStyle(color: Colors.orange, fontSize: 14)),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Icon(
                  Icons.fullscreen,
                  color: Colors.grey,
                  size: 22,
                ),
                Text(
                  " " + _data["area_size"].toString() + " m2",
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Icon(
                  Icons.people,
                  color: Colors.grey,
                  size: 22,
                ),
                Text(
                  " At most " + _data["people_capacity"].toString(),
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailInfo() {
    var location = _data["block"]["name"] + " - " + _data["level"]["name"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SimpleInfo(
          labelText: "Description",
          child: Text(_data["description"] ?? "Nothing"),
        ),
        SimpleInfo(
          labelText: "Location",
          child: Text(location),
        ),
        SimpleInfo(
          isHorizontal: true,
          marginBetween: 0,
          labelText: "Area: ",
          child: Text(
            _data["area"]["name"],
            style: TextStyle(color: Colors.blue),
          ),
        ),
        _getResourcesTags(),
      ],
    );
  }

  Widget _getResourcesTags() {
    var services = _data["resources"] as List<dynamic>;
    Widget widget = Text("Nothing");
    if (services != null) {
      var tags = services.map((e) => Text(e["name"])).toList();
      widget = TagsContainer(tags: tags);
    }
    return SimpleInfo(
      labelText: 'Resources',
      child: widget,
    );
  }
}

class _RoomDetailViewPresenter {
  _RoomDetailViewState view;

  _RoomDetailViewPresenter({this.view});

  void handleInitState(BuildContext context) {
    _getRoomDetail(view.code);
  }

  void _getRoomDetail(String code) {
    var success = false;
    RoomRepo.getDetail(
        code: code,
        error: view.showError,
        invalid: view.showInvalidMessages,
        success: (data) {
          success = true;
          view.loadRoomData(data);
        }).whenComplete(() => {if (!success) view.setShowingViewState()});
  }
}
