import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

class LoadingModal extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  LoadingModal({@required this.isLoading, @required this.child});

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    return LoadingOverlay(
      child: this.child,
      isLoading: this.isLoading,
      opacity: 0,
      progressIndicator: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
      ),
    );
  }
}
