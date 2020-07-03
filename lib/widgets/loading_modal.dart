import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

class LoadingModal extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  LoadingModal({@required this.isLoading, @required this.child});

  @override
  _LoadingModalState createState() =>
      _LoadingModalState(isLoading: this.isLoading, child: this.child);
}

class _LoadingModalState extends State<LoadingModal> {
  bool isLoading;
  Widget child;

  _LoadingModalState({@required this.isLoading, @required this.child});

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      child: this.child,
      isLoading: this.isLoading,
      opacity: 0,
      progressIndicator: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
      ),
    );
  }
}
