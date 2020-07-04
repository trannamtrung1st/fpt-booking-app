import 'package:flutter/material.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/widgets/app_button.dart';
import 'package:fptbooking_app/widgets/app_card.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';
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
  dynamic data = <String, dynamic>{
    'room': <String, dynamic>{'code': 'R9124'},
    'status': 'Processing',
    'booked_date': '18/04/1999',
    'from_time': '13:00',
    'to_time': '14:00',
    'num_of_people': 10,
    'attached_services': [
      <String, dynamic>{'code': 'TB', 'name': 'Tea break'},
      <String, dynamic>{'code': 'PRJ', 'name': 'Projector'},
    ],
    'book_person': 'trungtnse13@fpt.edu.vn',
    'using_person': ['trungtnse13@fpt.edu.vn', 'abc@fpt.edu.vn'],
    'note':
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed nec cursus urna, quis accumsan eros. Proin et neque dignissim nulla elementum sodales nec quis magna. In eu malesuada nulla. Fusce pulvinar sem non neque imperdiet maximus. Sed eu ornare nisi, sit amet mattis leo. Etiam consequat arcu sed efficitur faucibus',
    'feedback': null,
    'manager_message': 'This is the manager message'
  };

  _BookingDetailViewState({@required this.id});

  _BookingDetailViewPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = _BookingDetailViewPresenter(view: this);
    _presenter.handleLoadingData(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingData()) {
      return _buildLoadingDataWidget(context);
    }
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  Widget _buildShowingViewWidget(BuildContext context) {
    return _bookingInfo();
  }

  //isLoadingData
  bool isLoadingData() => _state == LOADING_DATA;

  void setLoadingDataState() => setState(() {
        _state = LOADING_DATA;
      });

  Widget _buildLoadingDataWidget(BuildContext context) {
    return _bookingInfo(loading: true);
  }

  void showInvalidMessages(List<String> mess) {
    DialogHelper.showMessage(context: context, title: "Sorry", contents: mess);
  }

  void showError() {
    DialogHelper.showUnknownError(context: this.context);
  }

  //widgets
  Widget _bookingInfo({bool loading = false}) {
    return Scaffold(
        appBar: ViewHelper.getDefaultAppBar(title: "Calendar detail"),
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: LoadingModal(
              isLoading: loading,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(15),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "BOOKING INFORMATION",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SimpleInfo(
                        labelText: 'Room',
                        child: Text(
                          data["room"]["code"],
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      SimpleInfo(
                        labelText: 'Status',
                        child: ViewHelper.getTextByBookingStatus(
                            status: data["status"]),
                      ),
                      _getTimeStr(),
                      SimpleInfo(
                        labelText: 'Number of people',
                        child: Text(data["num_of_people"].toString()),
                      ),
                      _getAttachedServicesTags(),
                      SimpleInfo(
                        labelText: 'Booking person',
                        child: Text(
                          data["book_person"],
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      SimpleInfo(
                        labelText: 'Using person(s)',
                        child: Text(
                          (data["using_person"] as List<String>).join(', '),
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      SimpleInfo(
                        labelText: 'Note',
                        child: Text(data["note"]),
                      ),
                      SimpleInfo(
                        labelText: 'Feedback',
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: "#DDDDDD".toColor())),
                          padding: EdgeInsets.all(8.0),
                          child: TextField(
                            maxLines: 7,
                            onChanged: (value) => data["feedback"] = value,
                            controller: new TextEditingController.fromValue(
                                new TextEditingValue(
                                    text: data["feedback"] ?? "",
                                    selection: new TextSelection.collapsed(
                                        offset:
                                            (data["feedback"] ?? "").length))),
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration.collapsed(
                                hintText: "Enter your text here"),
                          ),
                        ),
                      ),
                      SimpleInfo(
                        labelText: 'Manager message',
                        child: Text(data["manager_message"]),
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
              ),
            )));
  }

  Widget _getAttachedServicesTags() {
    var services = data["attached_services"] as List<dynamic>;
    var tags = services.map((e) => Text(e["name"])).toList();
    return SimpleInfo(
      labelText: 'Attached services',
      child: TagsContainer(tags: tags),
    );
  }

  Widget _getTimeStr() {
    return SimpleInfo(
        labelText: 'Status',
        child: Text(data["booked_date"] +
            ", " +
            data["from_time"] +
            " - " +
            data["to_time"]));
  }
}

class _BookingDetailViewPresenter {
  _BookingDetailViewState view;

  _BookingDetailViewPresenter({this.view});

  void handleLoadingData(BuildContext context) {
    view.setShowingViewState();
  }
}
