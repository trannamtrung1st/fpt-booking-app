import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppButton extends StatelessWidget {
  final Function onPressed;
  final Widget child;
  final String type;

  AppButton({this.onPressed, this.child, this.type});

  @override
  Widget build(BuildContext context) {
    Color btnColor = Colors.transparent, textColor = Colors.black;
    switch (type) {
      case "primary":
        btnColor = Colors.orange;
        textColor = Colors.white;
        break;
      case "danger":
        btnColor = Colors.redAccent;
        textColor = Colors.white;
        break;
      case "success":
        btnColor = Colors.green;
        textColor = Colors.white;
        break;
    }
    return RaisedButton(
      color: btnColor,
      textColor: textColor,
      onPressed: this.onPressed,
      child: this.child,
    );
  }
}
