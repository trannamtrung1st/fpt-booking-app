import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';

class TabView extends StatelessWidget {
  final Widget child;

  TabView({this.child});

  @override
  Widget build(BuildContext context) {
    return Material(child: this.child, color: "#F5F5F5".toColor());
  }
}
