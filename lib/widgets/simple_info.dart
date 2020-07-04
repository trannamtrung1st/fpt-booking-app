import 'package:flutter/widgets.dart';

class SimpleInfo extends StatelessWidget {
  final String labelText;
  final Widget child;

  SimpleInfo({@required this.labelText, this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 7),
          child: Text(labelText, style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        child
      ],
    );
  }
}
