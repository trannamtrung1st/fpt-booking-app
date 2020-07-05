import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';

class Tag extends StatelessWidget {
  final Widget child;
  final Function onRemove;
  final Function onTap;
  final Builder builder;

  Tag({this.child, this.onRemove, this.onTap, this.builder});

  @override
  Widget build(BuildContext context) {
    if (builder != null) return builder.build(context);
    var widgets = <Widget>[child];
    if (onRemove != null)
      widgets.add(Container(
          margin: EdgeInsets.only(left: 7),
          child: InkWell(
            onTap: onRemove,
            child: Icon(
              Icons.cancel,
              size: 20,
              color: "#CCCCCC".toColor(),
            ),
          )));
    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
    Widget finalTag = Container(
        padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
        decoration: BoxDecoration(
            color: "#CCCCCC".toColor(),
            borderRadius: BorderRadius.all(Radius.circular(40))),
        child: row);
    if (onTap != null)
      finalTag = InkWell(
        child: row,
        onTap: this.onTap,
      );
    return finalTag;
  }
}
