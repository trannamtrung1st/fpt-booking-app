import 'package:flutter/widgets.dart';

class SimpleInfo extends StatelessWidget {
  final String labelText;
  final Widget child;
  final double marginBetween;
  final double marginBottom;

  SimpleInfo(
      {@required this.labelText,
      this.child,
      this.marginBottom = 7,
      this.marginBetween = 7});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: marginBetween),
            child:
                Text(labelText, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          child
        ],
      ),
    );
  }
}
