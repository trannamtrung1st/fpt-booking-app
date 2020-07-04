import 'package:flutter/material.dart';
import 'package:fptbooking_app/helpers/dialog_helper.dart';
import 'package:fptbooking_app/widgets/loading_modal.dart';

class BookingDetailView extends StatefulWidget {
  BookingDetailView({key}) : super(key: key);

  @override
  _BookingDetailViewState createState() => _BookingDetailViewState();
}

class _BookingDetailViewState extends State<BookingDetailView> {
  static const int SHOWING_VIEW = 1;
  int _state = SHOWING_VIEW;

  _BookingDetailViewPresenter _presenter;

  @override
  Widget build(BuildContext context) {
    _presenter = _BookingDetailViewPresenter(view: this);
    return _buildShowingViewWidget(context);
  }

  //isShowingView
  void setShowingViewState() => setState(() {
        _state = SHOWING_VIEW;
      });

  Widget _buildShowingViewWidget(BuildContext context) {
    return LoadingModal(
      isLoading: false,
      child: Container(),
    );
  }

  void showInvalidMessages(List<String> mess) {
    DialogHelper.showMessage(context: context, title: "Sorry", contents: mess);
  }

  void showError() {
    DialogHelper.showUnknownError(context: this.context);
  }
}

class _BookingDetailViewPresenter {
  _BookingDetailViewState view;

  _BookingDetailViewPresenter({this.view});
}
