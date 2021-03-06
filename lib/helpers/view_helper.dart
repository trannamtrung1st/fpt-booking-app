import 'package:flutter/material.dart';

class ViewHelper {
  static AppBar getStackAppBar({@required String title, Function onPressed}) {
    return AppBar(
      leading: BackButton(
        onPressed: onPressed,
      ),
      backgroundColor: Colors.orange,
      title: Text(title),
    );
  }

  static AppBar getPageAppBar({@required String title, Icon icon}) {
    return AppBar(
      leading: icon,
      backgroundColor: Colors.orange,
      title: Text(title),
    );
  }

  static Widget getTextByBookingStatus(
      {@required String status, bool selectable = false}) {
    Color color = Colors.grey;
    switch (status) {
      case "Valid":
      case "Approved":
        color = Colors.green;
        break;
      case "Denied":
      case "Aborted":
        color = Colors.red;
        break;
      case "Finished":
        color = Colors.blue;
        break;
    }
    return selectable
        ? SelectableText(status, style: TextStyle(color: color))
        : Text(status, style: TextStyle(color: color));
  }
}
