import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DialogHelper {
  static Future<T> showCustomModalBottomSheet<T>({
    @required BuildContext context,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    @required Widget Function(BuildContext context) builder,
  }) async {
    return showModalBottomSheet<T>(
        context: context,
        builder: builder,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        isScrollControlled: isScrollControlled);
  }

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
    var currentVal = "";
    var textField = TextFormField(
        autofocus: false,
        onChanged: (val) => currentVal = val,
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
                  if (onCancel != null && !onCancel(currentVal)) return;
                  Navigator.of(context).pop(null);
                },
              ),
              FlatButton(
                child: Text(okBtnText),
                onPressed: () {
                  if (onOk != null && !onOk(currentVal)) return;
                  Navigator.of(context).pop(currentVal);
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

  static Future<bool> showConfirm({
    @required BuildContext context,
    List<String> contents,
    String title = "Confirm",
    bool barrierDismissible = false,
    String yesBtnText = "Yes",
    String noBtnText = "No",
    bool Function() onYes,
    bool Function() onNo,
  }) async {
    contents = contents ?? ["Are you sure?"];
    return showDialog<bool>(
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
              child: Text(noBtnText),
              onPressed: () {
                if (onNo != null && !onNo()) return;
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text(yesBtnText),
              onPressed: () {
                if (onYes != null && !onYes()) return;
                Navigator.of(context).pop(true);
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
