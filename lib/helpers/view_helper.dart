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
      case "Approved":
        color = Colors.green;
        break;
      case "Denied":
        color = Colors.red;
        break;
    }
    return Text(status, style: TextStyle(color: color));
  }
}
