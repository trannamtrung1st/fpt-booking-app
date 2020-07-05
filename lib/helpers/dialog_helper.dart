import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DialogHelper {
  static Future<String> prompt({
    @required BuildContext context,
    @required String title,
    bool barrierDismissible = false,
    TextInputType inputType = TextInputType.text,
    String cancelBtnText = "Cancel",
    String okBtnText = "Ok",
    String hintText = "Input here",
    bool Function(String text) onCancel,
    bool Function(String text) onOk,
  }) async {
    var textField = TextFormField(
        autofocus: false,
        keyboardType: inputType,
        maxLines: inputType == TextInputType.multiline ? 7 : 1,
        decoration: InputDecoration(
            hintText: hintText,
            contentPadding: EdgeInsets.only(bottom: 7),
            isDense: true));
    return showDialog<String>(
      context: context,
      barrierDismissible: barrierDismissible, // user must tap button!
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: textField,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(cancelBtnText),
                onPressed: () {
                  if (onCancel != null && !onCancel(textField.controller.text))
                    return;
                  Navigator.of(context).pop(null);
                },
              ),
              FlatButton(
                child: Text(okBtnText),
                onPressed: () {
                  if (onOk != null && !onOk(textField.controller.text)) return;
                  Navigator.of(context).pop(textField.controller.text);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showMessage({
    @required BuildContext context,
    @required List<String> contents,
    String title = "Message",
    bool barrierDismissible = false,
    String okBtnText = "Ok",
    bool Function() onOk,
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
                if (onOk != null && !onOk()) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showUnknownError(
      {@required BuildContext context, bool Function() onOk}) {
    return showMessage(
        context: context,
        title: "Sorry",
        contents: ["Something's wrong"],
        onOk: onOk);
  }
}
