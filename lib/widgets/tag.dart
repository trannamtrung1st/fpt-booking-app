import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';

class Tag extends StatelessWidget {
  final Widget child;

  Tag({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
        decoration: BoxDecoration(
            color: "#DDDDDD".toColor(),
            borderRadius: BorderRadius.all(Radius.circular(40))),
        child: child);
  }
}
