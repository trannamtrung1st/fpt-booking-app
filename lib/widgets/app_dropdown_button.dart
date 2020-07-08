
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';

class AppDropdownButton<T> extends StatelessWidget{

  final T value;
  final Function(T val) onChanged;
  final List<DropdownMenuItem> items;

  AppDropdownButton({this.value, this.onChanged, this.items});

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    return DropdownButton<T>(
      isDense: true,
      isExpanded: true,
      iconEnabledColor: Colors.black,
      value: value,
      icon: Icon(Icons.arrow_downward),
      iconSize: 20,
      elevation: 16,
      style: TextStyle(color: Colors.black),
      underline: Container(
        height: 1,
        color: "#CCCCCC".toColor(),
      ),
      onChanged: onChanged,
      items: items
    );
  }
}
