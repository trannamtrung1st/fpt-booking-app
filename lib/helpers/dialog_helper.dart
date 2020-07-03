import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DialogHelper {
  static Future<void> showMessage({
    @required BuildContext context,
    @required List<String> contents,
    String title = "Message",
    bool barrierDismissible = false,
    String okBtnText = "Ok",
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(children: contents.map((e) => Text(e)).toList()),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(okBtnText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showUnknownError({@required BuildContext context}) {
    return showMessage(
        context: context, title: "Sorry", contents: ["Something's wrong"]);
  }
}
