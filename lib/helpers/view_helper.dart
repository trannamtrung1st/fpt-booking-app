import 'package:flutter/material.dart';

class ViewHelper {
  static AppBar getDefaultAppBar({@required String title}) {
    return AppBar(
      leading: BackButton(),
      backgroundColor: Colors.orange,
      title: Text(title),
    );
  }
}
