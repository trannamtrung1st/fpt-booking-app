import 'package:flutter/material.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/repos/booking_repo.dart';
import 'package:fptbooking_app/widgets/app_button.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
import 'package:fptbooking_app/widgets/tag.dart';
import 'package:fptbooking_app/widgets/tags_container.dart';

class BookingDetailView extends StatefulWidget {
  final int id;

  BookingDetailView({key, this.id}) : super(key: key);

  @override
  _BookingDetailViewState createState() => _BookingDetailViewState(id: id);
}

class _BookingDetailViewState extends State<BookingDetailView> {
  static const int SHOWING_VIEW = 1;
  static const int LOADING_DATA = 2;
  int _state = LOADING_DATA;
  int id;
  dynamic _data;

  _BookingDetailViewState({@required this.id});

  _BookingDetailViewPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = _BookingDetailViewPresenter(view: this);
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
  void loadBookingData(dynamic data) {
    setState(() {
      _state = SHOWING_VIEW;
      _data = data;
    });
  }

  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  Widget _buildShowingViewWidget(BuildContext context) {
    return _mainContent(body: _data != null ? _bookingInfoCard() : Container());
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
        appBar: ViewHelper.getDefaultAppBar(title: "Calendar detail"),
        body: body);
  }

  Widget _bookingInfoCard() {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "BOOKING INFORMATION",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SimpleInfo(
                  labelText: 'Room',
                  child: Text(
                    _data["room"]["code"],
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                SimpleInfo(
                  labelText: 'Status',
                  child: ViewHelper.getTextByBookingStatus(
                      status: _data["status"]),
                ),
                _getTimeStr(),
                SimpleInfo(
                  labelText: 'Number of people',
                  child: Text(_data["num_of_people"].toString()),
                ),
                _getAttachedServicesTags(),
                SimpleInfo(
                  labelText: 'Booking person',
                  child: Text(
                    _data["book_person"],
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                SimpleInfo(
                  labelText: 'Using person(s)',
                  child: Text(
                    (_data["using_person"] as List<dynamic>).join(', '),
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                SimpleInfo(
                  labelText: 'Note',
                  child: Text(_data["note"] ?? ""),
                ),
                SimpleInfo(
                  labelText: 'Feedback',
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: "#DDDDDD".toColor())),
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      maxLines: 7,
                      onChanged: (value) => _data["feedback"] = value,
                      controller: new TextEditingController.fromValue(
                          new TextEditingValue(
                              text: _data["feedback"] ?? "",
                              selection: new TextSelection.collapsed(
                                  offset: (_data["feedback"] ?? "").length))),
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration.collapsed(
                          hintText: "Enter your text here"),
                    ),
                  ),
                ),
                SimpleInfo(
                  labelText: 'Manager message',
                  child: Text(_data["manager_message"] ?? ""),
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    AppButton(
                      type: "danger",
                      child: Text('ABORT'),
                      onPressed: () {},
                    ),
                    Spacer(),
                    AppButton(
                      type: "success",
                      child: Text('FEEDBACK'),
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Widget _getAttachedServicesTags() {
    var services = _data["attached_services"] as List<dynamic>;
    Widget widget = Text("Nothing");
    if (services != null) {
      var tags = services
          .map((e) => Tag(
                child: Text(e["name"]),
              ))
          .toList();
      widget = TagsContainer(tags: tags);
    }
    return SimpleInfo(
      labelText: 'Attached services',
      child: widget,
    );
  }

  Widget _getTimeStr() {
    return SimpleInfo(
        labelText: 'Status',
        child: Text(_data["booked_date"] +
            ", " +
            _data["from_time"] +
            " - " +
            _data["to_time"]));
  }
}

class _BookingDetailViewPresenter {
  _BookingDetailViewState view;

  _BookingDetailViewPresenter({this.view});

  void handleInitState(BuildContext context) {
    _getBookingDetail(view.id);
  }

  void _getBookingDetail(int id) {
    var success = false;
    BookingRepo.getDetail(
        id: id,
        error: view.showError,
        invalid: view.showInvalidMessages,
        success: (data) {
          success = true;
          view.loadBookingData(data);
        }).whenComplete(() => {if (!success) view.setShowingViewState()});
  }
}
