import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fptbooking_app/helpers/color_helper.dart';
import 'package:fptbooking_app/widgets/app_button.dart';
import 'package:fptbooking_app/widgets/simple_info.dart';

class ChangeRoomDialog extends StatelessWidget {
  final dynamic currentRoom;
  final Function(String value) onRoomTextChanged;
  final Function(String value) onCancelPressed;
  final Function(String value) onUpdatePressed;

  ChangeRoomDialog(
      {this.currentRoom,
      this.onRoomTextChanged,
      this.onCancelPressed,
      this.onUpdatePressed});

  @override
  Widget build(BuildContext context) {
    var text = "";
    return Material(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(15),
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "CHANGE ROOM",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SimpleInfo(
                labelText: "Current room",
                child: Text(currentRoom["code"]),
              ),
              SimpleInfo(
                labelText: "Change to",
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 14),
                  onChanged: (val) {
                    text = val;
                    if (onRoomTextChanged != null) onRoomTextChanged(val);
                  },
                  decoration: InputDecoration(
                      hintText: "Input room code",
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: "#CCCCCC".toColor())),
                      contentPadding: EdgeInsets.only(bottom: 7),
                      isDense: true),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  AppButton(
                    child: Text("CANCEL"),
                    type: "danger",
                    onPressed: () =>
                        onCancelPressed != null ? onCancelPressed(text) : null,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: AppButton(
                      child: Text("UPDATE"),
                      type: "success",
                      onPressed: () => onUpdatePressed != null
                          ? onUpdatePressed(text)
                          : null,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
