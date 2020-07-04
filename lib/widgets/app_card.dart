import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;

  AppCard({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
          margin: EdgeInsets.all(0),
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.all(15),
            child: this.child,
          )),
    );
  }
}
