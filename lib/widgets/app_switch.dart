import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppSwitch extends StatelessWidget {
  final bool value;
  final Function(bool val) onChanged;
  final String text;

  AppSwitch({@required this.value, @required this.text, this.onChanged});

  @override
  Widget build(BuildContext context) {
    print("build ${this.runtimeType}");
    return Row(
      children: <Widget>[
        Container(
          child: Switch.adaptive(
              value: value,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: onChanged),
        ),
        SelectableText(
          text,
          style: TextStyle(color: value ? Colors.black : Colors.grey),
        )
      ],
    );
  }
}
