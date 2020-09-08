import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppScroll extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final EdgeInsets padding;

  AppScroll({this.child, this.onRefresh, this.padding});

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    return RefreshIndicator(
      onRefresh: this.onRefresh,
      child: SingleChildScrollView(
        padding: padding,
        physics: AlwaysScrollableScrollPhysics(),
        child: this.child,
      ),
    );
  }
}
