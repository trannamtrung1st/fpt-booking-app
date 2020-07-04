import 'package:flutter/material.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/helpers/view_helper.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';

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
  dynamic data = <String, dynamic>{};

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
      body: LoadingModal(
        isLoading: loading,
        child: Center(
          child: Text(id.toString()),
        ),
      ),
    );
  }
}

class _BookingDetailViewPresenter {
  _BookingDetailViewState view;

  _BookingDetailViewPresenter({this.view});

  void handleLoadingData(BuildContext context) {
    view.setShowingViewState();
  }
}
