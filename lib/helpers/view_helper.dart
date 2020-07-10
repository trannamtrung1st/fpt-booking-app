import 'package:flutter/material.dart';

class ViewHelper {
  static AppBar getDefaultAppBar({@required String title, Function onPressed}) {
    return AppBar(
      leading: BackButton(
        onPressed: onPressed,
      ),
      backgroundColor: Colors.orange,
      title: Text(title),
    );
  }

  static Widget getTextByBookingStatus({@required String status}) {
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
    return SelectableText(status, style: TextStyle(color: color));
  }
}
