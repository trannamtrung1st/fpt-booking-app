import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final Function onTap;

  AppCard({this.child, this.onTap, this.margin = EdgeInsets.zero, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: this.margin,
      child: Card(
          margin: EdgeInsets.all(0),
          color: Colors.white,
          child: _btnOrContainer()),
    );
  }

  Widget _btnOrContainer() {
    if (this.onTap != null)
      return InkWell(
        onTap: this.onTap,
        child: _view(),
      );
    return _view();
  }

  Widget _view() {
    return Container(
      padding: EdgeInsets.all(15),
      child: this.child,
    );
  }
}
